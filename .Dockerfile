# ---------- Build stage ----------
FROM golang:1.22-alpine AS builder
WORKDIR /src

# Modülleri önce indir (cache dostu)
COPY go.mod go.sum ./
RUN go mod download

# Uygulama kaynakları
COPY . .

# Statik linkli, küçük bir binary üret
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/word-cloud-generator ./main.go

# ---------- Runtime stage ----------
# Distroless: minimize attack surface
FROM gcr.io/distroless/static-debian12
WORKDIR /app

# Binary + runtime'da gereken dosyalar
COPY --from=builder /out/word-cloud-generator /app/word-cloud-generator
COPY static ./static
COPY templates ./templates

# Uygulaman portu
EXPOSE 8888

# Non-root kullanıcı
USER 65532:65532

ENTRYPOINT ["/app/word-cloud-generator"]