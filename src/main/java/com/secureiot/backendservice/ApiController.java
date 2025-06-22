package com.secureiot.backendservice;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/hello")
public class ApiController {

    @GetMapping
    public String hello() {
        return "Hello from the secure IoT backend service!";
    }
}
