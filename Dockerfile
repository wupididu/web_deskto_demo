# Stage 1: Build environment with Flutter and Rust
FROM debian:latest AS build-env

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_HOME=/opt/flutter
ENV FLUTTER_VERSION=3.29.2
ENV PATH=$FLUTTER_HOME/bin:$PATH
ENV CARGO_HOME=/usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup
ENV PATH=$CARGO_HOME/bin:$PATH

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    build-essential \
    pkg-config \
    libssl-dev \
    clang \
    cmake \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN rustup target add wasm32-unknown-unknown

# Install wasm-pack
RUN cargo install wasm-pack

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME -b stable
RUN cd $FLUTTER_HOME && git fetch && git checkout $FLUTTER_VERSION
RUN flutter doctor

# Set working directory
WORKDIR /app

RUN pwd && ls

# Copy the application code
COPY . .

# Build the Rust WASM component
RUN chmod +x build_wasm.sh && ./build_wasm.sh

# Build the Flutter web application
RUN flutter clean
RUN flutter pub get
RUN flutter build web --wasm --release

# Stage 2: Create a lightweight web server
FROM nginx:1.25.2-alpine

# copy the info of the builded web app to nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html
COPY --from=build-env /app/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]