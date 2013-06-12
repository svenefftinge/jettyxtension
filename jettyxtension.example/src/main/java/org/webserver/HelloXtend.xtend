package org.webserver

import org.eclipse.jetty.server.Server
import de.itemis.jettyxtension.HttpHandler
import de.itemis.jettyxtension.Get

@HttpHandler class HelloXtend {

	@Get('/sayHello/:name') def sayHello() '''
		<html>
			<title>Hello «name»!</title>
			<body>
				<h1>Hello «name»!</h1>
			</body>
		</html>
	'''
	
	@Get('/sayHello/:firstName/:lastName') def sayHello() {
		sayHello(firstName+' '+lastName, target, baseRequest, request, response)
	}

    def static void main(String[] args) throws Exception {
        new Server(4711) => [
        	handler = new HelloXtend
        	start 
        	join
        ]
    }
	
}

