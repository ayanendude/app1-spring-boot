package com.personal.ayanendu.App1springboot.TestHello;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/rest/docker/hello")
public class TestHello {
    @GetMapping
    public String hello (){
        return "Hello World 78";
    }
}
