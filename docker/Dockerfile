#=====================#
# Stage 1: Base
#=====================#
FROM julia:1.10.6-bookworm AS base

# Create working directory
RUN mkdir /app
WORKDIR /app

#=====================#
# Stage 2: Builder
#=====================#
FROM base AS build

# Copy Project.toml and Manifest.toml
COPY Project.toml Manifest.toml ./

# Install dependencies
RUN julia --project=. -e 'using Pkg; Pkg.activate("."); Pkg.instantiate()'

# Precompile packages
RUN julia --project=. -e 'using Pkg; Pkg.precompile()'

#=====================#
# Stage 3: Production
#=====================#
FROM build AS production

# Copy source code
COPY src ./src
COPY run_server.jl .

# Precompile source
RUN julia --project=. -e 'using Pkg; Pkg.precompile()'

# Entrypoint command
ENTRYPOINT [ "julia", "--project=.", "run_server.jl" ]
