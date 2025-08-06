# Use the official PostgreSQL image
FROM postgres:15-alpine

ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG POSTGRES_DB

# Set default environment variables for PostgreSQL (can be overridden)
ENV POSTGRES_DB=${POSTGRES_DB:-catsdb}
ENV POSTGRES_USER=${POSTGRES_USER:-postgres}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-password}

# Copy the SQL initialization script to the docker-entrypoint-initdb.d directory
# Scripts in this directory are automatically executed when the container starts
COPY create-data.sql /docker-entrypoint-initdb.d/

# Expose the default PostgreSQL port
EXPOSE 5432

# The postgres image already has a default CMD, so we don't need to specify one
# The container will automatically start PostgreSQL and run our initialization script
