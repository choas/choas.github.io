---
layout:  post
title:   Docker Compose and Nginx
date:    2020-11-24 21:15 +0100
image:   track-2906667_1280.jpg
credit:  https://pixabay.com/photos/track-railroad-track-rails-railway-2906667/
tags:    docker-compose raspberry-pi
excerpt: In this example I split a webservice into two applications and merge them together with Nginx. I also use docker-compose.
---

> A reverse proxy accepts a request from a client, forwards it to a server that can fulfill it, and returns the server’s response to the client. -- [What is a Reverse Proxy vs. Load Balancer?](https://www.nginx.com/resources/glossary/reverse-proxy-vs-load-balancer/)

I played around with the Docker Compose example from my blog post [Docker Compose and Raspberry Pi](2020/11/16/docker-compose-and-raspberry-pi/). The application uses two REST calls. One to create a key-value pair and the other to read the value of the key. The values are stored in a Redis database.

I wanted to extend the example with Nginx as reverse proxy. Therefore, I split the two REST calls into two applications each. One writes, the other reads and Nginx merges both.

This would also allow to configure a load balancer. But since everything is running on a single machine the load balancing does not make much sense.

## Setup

This setup is based on the article [A Docker/docker-compose setup with Redis and Node/Express](https://codewithhugo.com/setting-up-express-and-redis-with-docker-compose/) and the code [HugoDF/express-redis-docker](https://github.com/HugoDF/express-redis-docker) which I adapt.

### docker-compose.yml

First, we look at the original [docker-compose.yml](https://github.com/HugoDF/express-redis-docker/blob/master/docker-compose.yml) file. The file defines the Redis database and the application:

```YAML
redis:
  image: redis
  container_name: cache
  expose:
    - 6379
app:
  build: ./
  volumes:
    - ./:/var/www/app
  links:
    - redis
  ports:
    - 3000:3000
  environment:
    - REDIS_URL=redis://cache
    - NODE_ENV=development
    - PORT=3000
  command:
    sh -c 'npm i && node server.js'
```

I leave the Redis container untouched and split the app into _app-set_ and _app-get_ and adjust the 'command' entry:

```YAML
app-set:
  build: ./
  volumes:
    - ./:/var/www/app
  links:
    - redis
  expose:
    - 3000
  environment:
    - REDIS_URL=redis://cache
    - NODE_ENV=development
    - PORT=3000
  command:
    sh -c 'npm i && node server-set.js'

app-get:
  build: ./
  volumes:
    - ./:/var/www/app
  links:
    - redis
  expose:
    - 3000
  environment:
    - REDIS_URL=redis://cache
    - NODE_ENV=development
    - PORT=3000
  command:
    sh -c 'npm i && node server-get.js'
```

I also changed the 'ports' entry to an 'expose' entry (see __exports vs ports__ at my blog post [Docker Compose and Raspberry Pi](http://localhost:4000/2020/11/16/docker-compose-and-raspberry-pi/#expose-vs-ports)) because the app servers are only accessed within the Docker Compose network and not from outside. For an outside access I use Nginx:

```YAML
nginx:
  build: ./nginx
  links:
    - app-set
    - app-get
  ports:
    - 3000:80
```

For the Nginx container I use a separate docker file, because I use a custom [nginx.conf](https://github.com/choas/express-redis-nginx-docker/blob/main/nginx/nginx.conf) file to _connect_ the two servers. With the 'links' entries I indicate that the container depends on the two applications. Nginx is running on port 80, I map it to port 3000 as the original example did.

Let's have a look at the docker file:

```Docker
FROM nginx
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
```

This uses the current Nginx image, deletes the default.conf file and copies my nginx.conf file:

```YAML
server {
  location /store/ {
    proxy_pass         http://app-set:3000;
  }  
  
  location / {
    proxy_pass         http://app-get:3000;
  }
}
```

Both applications run on port 3000, but since they use different hostnames this is not a problem. With a '/store/' request Nginx calls the 'app-set' application and returns the response. Otherwise, Nginx calls the 'app-get' application.

I copied the original [server.js](https://github.com/HugoDF/express-redis-docker/blob/master/server.js) file and removed the routing definitions which were not needed. If you start everything with `docker-compose up` the requests work as expected. I have the complete example on Github: [choas/express-redis-nginx-docker](https://github.com/choas/express-redis-nginx-docker)

## Summary

With this example I wanted to try out how I can break up and re-assemble a web service that could consist of different tasks.

Of course, the application also runs on a Raspberry Pi. But an error can occur at the first start because both applications call `npm install` and write to the same directory.

Any comments? Write me on Twitter [@choas](https://twitter.com/choas) (DM is open).
