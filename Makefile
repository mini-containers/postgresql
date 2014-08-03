build: Dockerfile
	docker build -t mini-postgresql .

tag:
	docker tag mini-postgresql mini/postgresql
