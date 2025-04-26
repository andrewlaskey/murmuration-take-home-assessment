# Murmuration Research Engineer Exercise

Hi! Here is my submission for the take-home exercise for the Research Engineer role. The goal of this task was to set up a few services and necessary infrastructure for analyzing survey data. It included:

* Create an API for uploading CSV data with survey responses and endpoints for fetching the data.
* Create a frontend interface for visualizing responses to a particular survey question
* Setup/Outline the infrastructure for deploying these services

## Overview of this project

I have organized the project as a monorepo with several sub directories.

* `/backend` contains the API service that interacts with a Postgres database for storing and retrieving survey data
* `/frontend` is a Next.js app with a single page that renders a simple question responses viewer
* `/bruno` this is a collection of requests using the [Bruno App](https://docs.usebruno.com/introduction/what-is-bruno) similar to other apps like Postman or Insomnia
* `/sample-data` has the CSV of test data
* `/terraform` contains the terraform config files

### Setup and running locally

The backend, frontend, and database can all be created and run with Docker compose.

```bash
docker-compose up --build
```

Once the services are running the API is accessible at `localhost:8000/api/v1/*`, and the frontend can be loaded in a browser at `localhost:3000`.

## Notes

### Backend

The Survey API is built with FastAPI, SQL Alchemy as an ORM, and Alembic for database migrations.

### Frontend

I configured the Next.js app to use Typescript and  Tailwind. I also used [Recharts](https://recharts.org/en-US) for all the graphing.

### Infra

The terraform is configured to set up an RDS Postrgres instance, two ECS clusters, and networking infra.

I didn't include it in this project, but in a real-world project I would also set up a CI/CD pipeline using Github Actions. This would run on pushes to `main` and would run tests, check for linting error, build container images, and push the images to Amazon ECS.

### On AI

I've been seeing a lot about the troubles hiring managers are having with candidates using AI, and the whole "vibe coding" practice, so I want to be transparent with how I use AI in general and specifically with this exercies.

At my last company the CEO was bullish on the use of AI for everyone, not just engineers, within the company and we were all given access to ChatGPT Plus plans and Copilot. I used it regularly in a few different ways. From debugging, as a supercharged find-replace, to write boilerplate code before I got to the complicated stuff, help me better understand an API's library's docs by giving me more concrete examples, or to find solutions to problems I previously would have searched for on StackOverflow.

I've also used it extensivly to learn new things. For example at my last job we were asked to build services that interacted with LLM APIs using Python.  ChatGTP was very helpful to me to translate my general programming knowledge from javascript or Typescript into Python. Or recently for a hobby project, I've been using it to teach myself three.js and GSAP.

For this exercise I did use Claude as a coding assistant. Mainly I used it to make sure I was setting up the Survey API correctly. I used SQLAlchemy and Alembic at my last job for one of our services but I was mainly extending that service and hadn't built a Python server from scratch. I also used it to help with the Docker configuration, where again my experience has been more editing existing configs that our DevOps engineers wrote. And finally along the same lines the terraform I generated mainly through a bit of back-and-forth prompting. Again at my last company I had the benefit of being able to rely on talented DevOps engineers to configure things based on the requirements I gave them and depended on their knowledge of the intracacies of AWS. That said I try to understand Claude's output as its necessary to make sure it actually is doing what you want it to do. But I have had success recently on a contract setting up and deploying services to GCP with Github Actions and Terraform this way.