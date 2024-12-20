import http.server
import socketserver
import os
from socketserver import ThreadingMixIn
import signal
import sys
import logging
import socket

# Configure logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

PORT = 8000
DIRECTORY = "public"

# Change the current working directory to the public folder
os.chdir(DIRECTORY)

class ThreadedHTTPServer(ThreadingMixIn, socketserver.TCPServer):
    """Handle requests in a separate thread."""
    pass

# Request handler with logging
class LoggingHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def log_request(self, code='-', size='-'):
        logging.info(f"Request: {self.path}, Code: {code}, Size: {size}")

# Timeout handler (in case of slow clients or requests)
def timeout_handler():
    socket.setdefaulttimeout(10)  # Set a timeout of 10 seconds for client connections

# Graceful shutdown handler
def signal_handler(sig, frame):
    logging.info("\nServer shutting down gracefully...")
    httpd.shutdown()
    sys.exit(0)

# Main function to start the server
def start_server():
    # Set the signal handler for graceful shutdown
    signal.signal(signal.SIGINT, signal_handler)
    
    # Set a timeout for socket connections (this is to handle slow clients)
    timeout_handler()

    # Set up the handler for requests
    Handler = LoggingHTTPRequestHandler

    # Set up the threaded server
    with ThreadedHTTPServer(("", PORT), Handler) as httpd:
        logging.info(f"Serving on port {PORT}, with the root directory as '{DIRECTORY}'")
        # Start serving requests
        httpd.serve_forever()

if __name__ == "__main__":
    start_server()
