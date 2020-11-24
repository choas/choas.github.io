---
layout:  post
title:   Docker Compose and Raspberry Pi
date:    2020-11-16 22:19 +0100
image:   ben-koorengevel-rpMwfGLSsd8-unsplash.jpg
credit:  https://unsplash.com/photos/rpMwfGLSsd8
tags:    docker-compose raspberry-pi
excerpt: docker-compose defines and executes a microservice application that is structured as a multi-container docker application.
---

> Compose is a tool for defining and running multi-container Docker applications. With Compose, you use a YAML file to configure your application’s services. — [Overview of Docker Compose](https://docs.docker.com/compose/)

In my blog post [Raspberry Pi and Docker](/2020/10/31/raspberry-pi-and-docker/) I describe how I installed Docker on a Raspberry Pi. This allows me, for example, to run a small NodeJs application that is always online and available on the local network. Because of the current situation I'm at home anyway. Therefore, I don't need to open a port in the firewall or deploy the application on AWS.

## Docker Compose

My application has a dependency on a database (e.g. [redis](https://redis.io/)) and a [MQTT Broker](https://mosquitto.org/), and I want to bundle them. This is where [Docker Compose](https://docs.docker.com/compose/) comes in. With Docker Compose a multi-container Docker application can be defined and executed.

The [features](https://docs.docker.com/compose/#features) of Compose that make it effective are:

- Multiple isolated environments on a single host
- Preserve volume data when containers are created
- Only recreate containers that have changed
- Variables and moving a composition between environments

## Install Docker Compose

Docker Compose can be installed on a computer or Raspberry Pi. The [Install Docker Compose](https://docs.docker.com/compose/install/) page on docker.com has a detailed description. I installed it with `pip3` on the Raspberry Pi:

```bash
sudo apt-get install python3-pip
pip3 install docker-compose
```

## Docker Compose Example

The article [A Docker/docker-compose setup with Redis and Node/Express](https://codewithhugo.com/setting-up-express-and-redis-with-docker-compose/) describes an example of Docker Compose with redis and [express](https://expressjs.com/). It includes all necessary NodeJs, Docker and Docker Compose files to build a small REST service. This service stores a key-value pair in redis. The code is on Github available: [HugoDF/express-redis-docker](https://github.com/HugoDF/express-redis-docker).

### The docker-compose.yml file

The [docker-compose.yml](https://github.com/HugoDF/express-redis-docker/blob/master/docker-compose.yml) file from the example looks like this:

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

The file, which is written in [YAML](https://en.wikipedia.org/wiki/Yaml) format, is divided into two parts. One part is the _redis_ configuration and the other part is the _app_ configuration. The _redis_ configuration uses a redis Docker image, names the container 'cache' and exposes the standard redis port 6379.

The _app_ configuration uses _build_ to use the Dockerfile file in the current directory and _volumes_ mounts the current directory to __/var/www/app__.

By default, each service can reach any other service under the name of that service. _[links](https://docs.docker.com/compose/compose-file/#links)_ are not necessary, but document which service is used (see also [Infrastructure as code](https://www.thoughtworks.com/radar/techniques/infrastructure-as-code)).

_[ports](https://docs.docker.com/compose/compose-file/#ports)_ exposes the service port. In this case the host system can reach the service on port 3000.

You can define [environment](https://docs.docker.com/compose/compose-file/#environment) variables. For example, a redis database which contains test data can be used during development.

The command entry contains the instructions that are executed inside the container when Docker Compose builds the container. In the example `npm i` installs all NodeJs libraries and then starts the `server.js` with the application.

The _app_ uses the following [Dockerfile](https://github.com/HugoDF/express-redis-docker/blob/master/Dockerfile), which uses a long-term support (LTS) node container and specifies the _WORKDIR_ which is mounted inside the docker-compose.yml file to the current directory.

```Docker
FROM node:lts
# Or whatever Node version/image you want
WORKDIR '/var/www/app'
```

### expose vs ports

In the docker-compose.yml example both _expose_ and _ports_ are listed. What is the difference?

"_[expose](https://docs.docker.com/compose/compose-file/#expose)_ ports without publishing them to the host machine - they’ll only be accessible to linked services. Only the internal port can be specified."

With _[ports](https://docs.docker.com/compose/compose-file/#ports)_ the container publishes the port to the host machine and can be reached from there. The configured port of the host machine accesses the corresponding port on the application in the Docker container.

Docker Compose creates its own network which can be seen with `docker network ls`. The communication is only inside this network. So, you don't have to worry about open 🔓 ports. The respective application names are used for the hostname. With this hostname you can reach them, but only within the Docker network.

### The Application

The application has two REST interfaces. With `/store/:key?query` the _query_ is stored as value of the key in the redis database. `/:key` reads the key from the redis database and returns the value.

```JavaScript
const redisClient = require('./redis-client');

app.get('/store/:key', async (req, res) => {
    const { key } = req.params;
    const value = req.query;
    await redisClient.setAsync(key, JSON.stringify(value));
    return res.send('Success');
});

app.get('/:key', async (req, res) => {
    const { key } = req.params;
    const rawData = await redisClient.getAsync(key);
    return res.json(JSON.parse(rawData));
});
```

You can find the complete code of the [server.js](https://github.com/HugoDF/express-redis-docker/blob/master/server.js) at the Github project.

### Test

To test it, the containers are created and started as follows:

```bash
docker-compose up
```

… then store a key-value pair using [cURL](https://en.wikipedia.org/wiki/CURL) to call the service running on port 3000:

```bash
curl http://pi2:3000/store/my-key\?some\=value\&some-other\=other-value
```

… and read the value:

```bash
curl http://pi2:3000/my-key
```

As you can see in the URL, I run it on a Raspberry Pi. In case you read my blog post [Load Average on 7-Segment](/2020/10/18/load-average-on-7-segment/) you know that I show the load average and the free disk space on a 7-segment display. This example took 0.02 gigabyte disk space. The load average went up but went back to 0.00 although the two Docker images are running. Only when I make several calls the value goes up.

## Summary

A docker-compose.yml file documents the configuration of the necessary containers and is [Infrastructure as code](https://www.thoughtworks.com/radar/techniques/infrastructure-as-code).

Furthermore, all necessary components are configured and started, and they are defined for development as well as production. In case there are differences (e.g. an SSL certificate for production), Docker Compose offers a simple way to configure the differences within a second file.

More tips are available in the article [10 Tips for Docker Compose Hosting in Production](https://blog.cloud66.com/10-tips-for-docker-compose-hosting-in-production/).

Any comments? Write me on Twitter [@choas](https://twitter.com/choas) (DM is open).
