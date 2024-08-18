# Stage 1: Build the Node.js application
FROM node:20.8.0 AS frontend-builder

WORKDIR /Frontend

COPY ./Frontend/package.json ./Frontend/package-lock.json ./
RUN npm install

COPY ./Frontend .
RUN npm run build

# Stage 2: Build the Go application
FROM golang:1.23 AS builder

WORKDIR /Backend

COPY ./Backend/go.mod ./Backend/go.sum ./
RUN go mod download

COPY ./Backend .
RUN go build -o main ./cmd/app/main.go

# Stage 3: Final image
FROM golang:1.23

WORKDIR /Backend

# Copy the Go binary from the builder stage
COPY --from=builder /Backend .

# Copy the frontend build artifacts from the frontend-builder stage
COPY --from=frontend-builder /Frontend /Frontend

EXPOSE 8080

CMD ["./main"]