package fr.itix.vulnerablecontainers.httpserver;

import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    Logger logger = LogManager.getLogger(HelloController.class);

	@GetMapping("/")
	public String index(@RequestHeader Map<String, String> headers) {
		String name = headers.get("x-name");
        
		if (name != null && ! "".equals(name)) {
			logger.info("Request from {}", name);
			return "Hello, " + name + "!";
		}
		
		return "Hello, world!";
	}

}
