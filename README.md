jettyxtension
=============

Small REST API on top of Jetty, built with Xtend (http://xtend-lang.org)

```xtend
@HttpHandler class HelloXtend {

  @Get('/sayHello/:name') def sayHello() '''
    <html>
      <title>Hello «name»!</title>
      <body>
        <h1>Hello «name»!</h1>
      </body>
    </html>
  '''
 
  @Get('/sayHello/:firstName/:LastName') def sayHello() '''
    <html>
      <title>Hello «firstName» «LastName»!</title>
      <body>
        <h1>Hello «firstName» «LastName»!</h1>
      </body>
    </html>
  '''

  def static void main(String[] args) throws Exception {
    new Server(4711) => [
      handler = new HelloXtend
      start 
      join
    ]
  } 
}
```
    

This is a single class with no further framework directly running an embedded Jetty server. The interesting part here is, that you don't have to redeclare the parameters, as the active `HttpHandler` annotation will automatically add them to the method. See the method is overloaded but both declare zero parameters? That's usually a compiler error, but here they actually have five resp. six parameters, because my annotation adds the parameters from the pattern in the `@Get` annotation as well as the original parameters from Jetty's handle method signature. Just so you can use them when needed.

Not only the compiler is aware of the changes caused by the annotation, but so is the IDE. Content assist, navigation, outline views etc. just work as expected.
