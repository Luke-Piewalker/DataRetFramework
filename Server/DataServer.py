from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import re
import json

response = "{\"providers\":[{\"id\":\"eyeota\",\"segments\":[\"gamer\",\"technology\",\"male_18-25\"]},{\"id\":\"nielsen\",\"segments\":[\"male\",\"male/18_to_25\",\"sports/rugby\",\"sports/football\",\"technology\",\"technology/gaming\"]},{\"id\":\"skimlinks\",\"segments\":[\"male\",\"purchase_intender:mobile_phones\"]}]}";

class S(BaseHTTPRequestHandler):
    global response

    def do_GET(self):
        if None != re.search('/api/v1/data\?user_id=*', self.path):
          self.send_response(200)
          self.send_header('Content-type', 'application/json')
          self.send_header('Access-Control-Allow-Origin', '*')
          self.end_headers()
          self.wfile.write(json.dumps(json.loads(response), sort_keys=True, indent=4, separators=(',', ': ')))
        else:
          self.send_response(404, 'Not Found: path does not exist')
          self.send_header('Access-Control-Allow-Origin', '*')
          self.end_headers()
        
def run(server_class=HTTPServer, handler_class=S, port=8080):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print 'Starting httpd...'
    httpd.serve_forever()

if __name__ == "__main__":
    from sys import argv

    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()