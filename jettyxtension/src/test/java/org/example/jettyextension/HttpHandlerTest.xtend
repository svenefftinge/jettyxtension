package org.example.jettyextension

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.example.jettyxtension.HttpHandler
import org.junit.Test

class HttpHandlerTest {
	
	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(typeof(HttpHandler))
	
	@Test def void testSimple() {
		'''
			import org.example.jettyxtension.HttpHandler
			import org.example.jettyxtension.Get
			
			@HttpHandler class MyHandler {
				@Get('foo/:bar') def doStuff() {
					'hello '+request.toString
				}
			}
		'''.assertCompilesTo('''
			import java.io.IOException;
			import java.util.regex.Matcher;
			import java.util.regex.Pattern;
			import javax.servlet.ServletException;
			import javax.servlet.http.HttpServletRequest;
			import javax.servlet.http.HttpServletResponse;
			import org.eclipse.jetty.server.Request;
			import org.eclipse.jetty.server.handler.AbstractHandler;
			import org.example.jettyxtension.Get;
			import org.example.jettyxtension.HttpHandler;
			
			@HttpHandler
			@SuppressWarnings("all")
			public class MyHandler extends AbstractHandler {
			  @Get("foo/:bar")
			  public String doStuff(final String bar, final String target, final Request baseRequest, final HttpServletRequest request, final HttpServletResponse response) {
			    String _string = request.toString();
			    String _plus = ("hello " + _string);
			    return _plus;
			  }
			  
			  public void handle(final String target, final Request baseRequest, final HttpServletRequest request, final HttpServletResponse response) throws IOException, ServletException {
			    {
			    	Matcher matcher = 
			    		Pattern.compile("foo\\/(\\w+)").matcher(target);
			    	if (matcher.matches()) {
			    		String bar = matcher.group(1);
			    		response.setContentType("text/html;charset=utf-8");
			    	    response.setStatus(HttpServletResponse.SC_OK);
			    	    response.getWriter().println(doStuff(bar, target, baseRequest, request, response));
			    	    baseRequest.setHandled(true);
			    	}
			    }
			    
			  }
			}
		''')
	}
}