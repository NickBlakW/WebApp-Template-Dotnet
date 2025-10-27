set quiet := true
import 'file_gen/cs.just'
import 'file_gen/docker.just'

add-service name: (_add-to-proxy snakecase(name)) (add-to-compose snakecase(name)) (generate-service-files name) (generate-dockerfile name)

tabs := "\t\t\t"
matchDef := '\n\t\t\t\t"Match": { "Path": '

_add-to-proxy name:
    sed -i '/"Routes": {/ a \{{tabs}}"{{name}}": {\n{{tabs}}\t"ClusterId": "{{name}}Cluster",{{matchDef}}"/{{name}}/{**catch-all}" }\n{{tabs}}},' Proxy/appsettings.json
    sed -i '/"Clusters": {/ a \{{tabs}}"{{name}}Cluster": {\n{{tabs}}\t"Destinations": {\n{{tabs}}\t\t"dest1": { "Address": "http://{{name}}:80/" }\n{{tabs}}\t\}\n{{tabs}}},' Proxy/appsettings.json
