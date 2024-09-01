# README

This README documents the steps necessary to get the application up and running.

## Prerequisites

### Ruby Version
- Ensure you are using the correct Ruby version as specified in the `.ruby-version` file. It's recommended to use a Ruby version manager like `asdf`.

#### Installing Ruby with `asdf`
1. Install `asdf` by following the instructions in the [asdf GitHub repository](https://github.com/asdf-vm/asdf).
2. Install the Ruby plugin: `asdf plugin add ruby`.
3. Install the required Ruby version: `asdf install`.

### System Dependencies
- **PostgreSQL**: This application uses PostgreSQL as its database. For macOS users, it is recommended to install Postgres using [Postgres.app](https://postgresapp.com/).

### Environment Variables
- **PG_USERNAME**: Set this to your PostgreSQL username.
- **STRIPE_ENDPOINT_SECRET**: Set this to your Stripe endpoint secret.

#### Setting Environment Variables with direnv
1. Install `direnv` following the instructions [here](https://direnv.net/docs/installation.html).
2. Create a `.envrc` file in your project root and add the following lines:

```bash
export PG_USERNAME=your_postgres_username
export STRIPE_ENDPOINT_SECRET=your_stripe_endpoint_secret
```

3. Allow the `.envrc` file with `direnv allow`.

## Configuration
- Configure your database connection in `config/database.yml` according to your PostgreSQL setup.

## Database Setup
1. Create the database:

```bash
rails db:create
```

2. Run migrations:

```bash
rails db:migrate
```

## How to Run the Test Suite
- Run the tests using RSpec:

```bash
rspec
```


## Subscribing to Stripe Events

### Install Stripe CLI
- Follow the instructions on [Stripe CLI documentation](https://stripe.com/docs/stripe-cli) to install the Stripe CLI.

### Forward Stripe Events to a Webhook Endpoint
- Use Stripe CLI to forward events to your local application:

```bash
stripe listen --forward-to localhost:3000/stripe_webhooks
```


## Architecture Overview

This application follows an **event-driven approach** and employs a **layered architecture** to separate concerns and improve maintainability. The layers are structured as follows:

- **Domain Layer**: Contains the core business logic and domain entities. It is the heart of the application and is independent of external frameworks.
- **Application Layer**: Responsible for orchestrating business use cases and managing the flow of data between the domain layer and external systems. It includes listeners and use cases.
- **Infrastructure Layer**: Handles external dependencies like databases, external APIs, and message queues. It includes repositories, external API handlers, ActiveRecord models, and jobs.
- **Interface Layer**: Manages user interfaces, controllers, and views. It’s responsible for handling HTTP requests and responses.

### Logical Structure

The following is a logical structure of the application. While models, views, controllers, and jobs follow the standard Rails directory structure, they are logically categorized into different layers as shown below:

app/
├── domains/                   # Domain layer
│   ├── billing/               # Billing domain
│   │   ├── entities/          # Domain entities
│   │   ├── events/            # Domain events
│   │   └── services/          # Domain services
├── application/               # Application layer
│   ├── use_cases/             # Application use cases
│   ├── listeners/             # Application listeners
├── infrastructure/            # Infrastructure layer
│   ├── repositories/          # Repositories for data access
│   ├── handlers/              # External API handlers
│   ├── models/                # ActiveRecord models
│   └── jobs/                  # Background jobs
└── interface/                 # Interface layer
    ├── controllers/           # Web controllers
    └── views/                 # Views

This logical structure ensures that the business logic is decoupled from the infrastructure and interface layers, facilitating easier maintenance and scalability.
