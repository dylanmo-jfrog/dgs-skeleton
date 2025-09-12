package fr.davidrobin.api.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@Configuration
public class GraphiQLConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/jfrog-demo/graphiql/**")
                .addResourceLocations("classpath:/static/");
    }
}

@RestController
class CustomGraphiQLController {
    
    @GetMapping("/jfrog-demo/graphiql")
    public ResponseEntity<String> graphiql() {
        String html = "<!DOCTYPE html>\n" +
            "<html>\n" +
            "<head>\n" +
            "    <title>GraphiQL</title>\n" +
            "    <style>\n" +
            "        body {\n" +
            "            height: 100%;\n" +
            "            margin: 0;\n" +
            "            width: 100%;\n" +
            "            overflow: hidden;\n" +
            "        }\n" +
            "        #graphiql {\n" +
            "            height: 100vh;\n" +
            "        }\n" +
            "    </style>\n" +
            "    <script\n" +
            "        crossorigin\n" +
            "        src=\"https://unpkg.com/react@17/umd/react.production.min.js\"\n" +
            "    ></script>\n" +
            "    <script\n" +
            "        crossorigin\n" +
            "        src=\"https://unpkg.com/react-dom@17/umd/react-dom.production.min.js\"\n" +
            "    ></script>\n" +
            "    <script\n" +
            "        crossorigin\n" +
            "        src=\"https://unpkg.com/graphiql@2.4.7/graphiql.min.js\"\n" +
            "    ></script>\n" +
            "    <link rel=\"stylesheet\" href=\"https://unpkg.com/graphiql@2.4.7/graphiql.min.css\" />\n" +
            "</head>\n" +
            "<body>\n" +
            "    <div id=\"graphiql\">Loading...</div>\n" +
            "    <script>\n" +
            "        function graphQLFetcher(graphQLParams) {\n" +
            "            return fetch('/jfrog-demo/graphql', {\n" +
            "                method: 'post',\n" +
            "                headers: {\n" +
            "                    'Accept': 'application/json',\n" +
            "                    'Content-Type': 'application/json',\n" +
            "                },\n" +
            "                body: JSON.stringify(graphQLParams),\n" +
            "            }).then(function (response) {\n" +
            "                return response.text();\n" +
            "            }).then(function (responseBody) {\n" +
            "                try {\n" +
            "                    return JSON.parse(responseBody);\n" +
            "                } catch (error) {\n" +
            "                    return responseBody;\n" +
            "                }\n" +
            "            });\n" +
            "        }\n" +
            "\n" +
            "        ReactDOM.render(\n" +
            "            React.createElement(GraphiQL, {\n" +
            "                fetcher: graphQLFetcher,\n" +
            "                defaultQuery: '{ shows { title platform releaseYear } }'\n" +
            "            }),\n" +
            "            document.getElementById('graphiql'),\n" +
            "        );\n" +
            "    </script>\n" +
            "</body>\n" +
            "</html>";
        
        return ResponseEntity.ok()
            .header("Content-Type", "text/html")
            .body(html);
    }
}
