[
    {
      "name": "${name}",
      "image": "${image}",
      "cpu": 256,
      "memory": 256,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 0,
          "protocol": "tcp"
        }
      ]
    }
  ]