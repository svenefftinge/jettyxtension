package org.example.jettyxtension

import java.io.IOException
import java.util.List
import java.util.regex.Matcher
import java.util.regex.Pattern
import javax.servlet.ServletException
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import org.eclipse.jetty.server.Request
import org.eclipse.jetty.server.handler.AbstractHandler
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.Type

@Active(typeof(HttpHandlerProcessor))
annotation HttpHandler {
}

annotation Get {
	String value
}

class HttpHandlerProcessor implements TransformationParticipant<MutableClassDeclaration> {
	
	override doTransform(List<? extends MutableClassDeclaration> annotatedTargetElements, extension TransformationContext context) {
		val httpGet = typeof(Get).findTypeGlobally
		for (clazz : annotatedTargetElements) {
			clazz.extendedClass = typeof(AbstractHandler).newTypeReference
			val annotatedMethods = clazz.declaredMethods.filter[findAnnotation(httpGet)?.getValue('value')!=null]
			
			// create the handle method
			clazz.addMethod('handle') [
				returnType = primitiveVoid
				addParameter('target', string)
				addParameter('baseRequest', typeof(Request).newTypeReference) 
				addParameter('request', typeof(HttpServletRequest).newTypeReference) 
				addParameter('response', typeof(HttpServletResponse).newTypeReference)
				
				setExceptions(typeof(IOException).newTypeReference, typeof(ServletException).newTypeReference)
				
				body = ['''
					«FOR m : annotatedMethods»
						{
							«toJavaCode(typeof(Matcher).newTypeReference)» matcher = 
								«toJavaCode(typeof(Pattern).newTypeReference)».compile("«m.getPattern(httpGet)»").matcher(target);
							if (matcher.matches()) {
								«var i = 0»
								«FOR v : m.getVariables(httpGet)»
									String «v» = matcher.group(«i=i+1»);
								«ENDFOR»
								response.setContentType("text/html;charset=utf-8");
							    response.setStatus(HttpServletResponse.SC_OK);
							    response.getWriter().println(«m.simpleName»(«m.getVariables(httpGet).map[it+', '].join»target, baseRequest, request, response));
							    baseRequest.setHandled(true);
							}
						}
					«ENDFOR»
				''']
			]
			
			// enhance get handler methods
			for (m : annotatedMethods) {
				for (variable : m.getVariables(httpGet)) {
					m.addParameter(variable, string)
				}
				m.addParameter('target', string)
				m.addParameter('baseRequest', typeof(Request).newTypeReference) 
				m.addParameter('request', typeof(HttpServletRequest).newTypeReference) 
				m.addParameter('response', typeof(HttpServletResponse).newTypeReference)
			}
		}
	}
	
	private def getVariables(MutableMethodDeclaration m, Type annotationType) {
		return m.getVariablesAndGroupedPattern(annotationType).value
	}
	
	private def getPattern(MutableMethodDeclaration m, Type annotationType) {
		return m.getVariablesAndGroupedPattern(annotationType).key
	}
	
	private def getVariablesAndGroupedPattern(MutableMethodDeclaration m, Type annotationType) {
		var pattern = m.findAnnotation(annotationType).getValue('value').toString
		val matcher = Pattern::compile('(:\\w+)').matcher(pattern)
		val builder = new StringBuilder
		var i = 0
		val variables = newArrayList
		while (matcher.find) {
			variables += matcher.group.substring(1)
			builder.append(pattern.substring(i, matcher.start).replace('/','\\\\/'))
			builder.append("(\\\\w+)")
			i = matcher.end
		}
		if (i<pattern.length)
			builder.append(pattern.substring(i, pattern.length-1))
		return builder.toString -> variables
	}
}
