# ecs-deploy-flask-example

Amazon ECS deployment example using CodePipeline and ecspresso

## Setup

install [ecspresso](https://github.com/kayac/ecspresso)
```
$ brew install ecspresso
```

## Usage

docker push ecspresso on ecr
```
$ cd ecspresso
$ aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin [aws account id].dkr.ecr.ap-northeast-1.amazonaws.com
$ docker build -t [aws account id].dkr.ecr.ap-northeast-1.amazonaws.com/ecspresso:v1.6.2 .
$ docker push [aws account id].dkr.ecr.ap-northeast-1.amazonaws.com/ecspresso:v1.6.2
```

create ecs service
```
$ cd ecspresso
$ TAG=[docker image tag] ecspresso create --config staging/ecspresso.yml
$ TAG=[docker image tag] ecspresso create --config production/ecspresso.yml
```
