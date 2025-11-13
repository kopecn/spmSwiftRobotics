# 2. Connecting to URControl

URControl is the low-level robot controller running on the Embedded PC in the Control Box cabinet. When the
PC boots up, the URControl starts up as a daemon (i.e., a service) and the PolyScope or Graphical User
Interface connects as a client using a local TCP/IP connection.
Programming a robot at the Script Level is done by writing a client application (running at another PC) and
connecting to URControl using a TCP/IP socket.
Hostname: ur-<serial number> (or the IP address found in the AboutDialog-Box in PolyScope if the robot is
not in DNS).
• port: 30002
When a connection has been established URScript programs or commands are sent in clear text on the
socket. Each line is terminated by “\n”. Note that the text can only consist of extended ASCII characters.
The following conditions must be met to ensure that the URControl correctly recognizes the script:
• The script must start from a function definition or a secondary function definition (either "def" or "sec"
keywords) in the first column
• All other script lines must be indented by at least one white space
• The last line of script must be an "end" keyword starting in the first column
Important:
It is recommended to always read data from the socket. At least 79 bytes have to be read from socket before
closing to ensure that underlying TCP protocol closes socket orderly. Otherwise data sent from client may be
discarded before script is executed.
It is especially important in cases when socket is opened just to send single script, and closed immediately.
It is recommended to keep sockets open instead of opening end closing for each and every request.