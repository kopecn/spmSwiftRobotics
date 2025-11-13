# 8. Remote Procedure Call (RPC)

Remote Procedure Calls (RPC) are similar to normal function calls, except that the function is defined and
executed remotely. On the remote site, the RPC function being called must exist with the same number of
parameters and corresponding types (together the function’s signature). If the function is not defined remotely,
it stops program execution. The controller uses the XMLRPC standard to send the parameters to the remote
site and retrieve the result(s). During an RPC call, the controller waits for the remote function to complete.
The XMLRPC standard is among others supported by C++ (xmlrpc-c library), Python and Java.
Creating a URScript program to initialize a camera, take a snapshot and retrieve a new target pose:
camera = rpc_factory("xmlrpc", "http://127.0.0.1/RPC2")
if (! camera.initialize("RGB")):
popup("Camera was not initialized")
camera.takeSnapshot()
target = camera.getTarget()
camera.closeXMLRPCClientConnection()
...
First the rpc_factory (see Interfaces section) creates an XMLRPC connection to the specified
remote server. The camera variable is the handle for the remote function calls. You must initialize the camera
and therefore call camera.initialize("RGB").
The function returns a boolean value to indicate if the request was successful. In order to find a target position,
the camera first takes a picture, hence the camera.takeSnapshot() call. Once the snapshot is taken, the
image analysis in the remote site calculates the location of the target. Then the program asks for the exact
target location with the function call target = camera.getTarget(). On return the target
variable is as- signed the result. The camera.initialize("RGB"), takeSnapshot() and
getTarget() functions are the responsibility of the RPC server.
The closeXMLRPCClientConnection is closing the XMLRPC connection created by the rpc_factory. It
is recommended to close the connection periodically, or when it's not used for a longer time. Some server
implementations by default have a limit of rpc requests or inactivity watchdog timers.
NOTE: The RPC handle does not automatically close the connecetion.
The technical support website: http://www.universal-robots.com/support contains more examples of XMLRPC
servers.

8.1. closeXMLRPCClientConnection()
Closes a Remote Procedure Call (RPC) handle.