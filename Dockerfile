ARG RABBITMQ_VERSION=3.13.7

FROM alpine AS downloader
ARG RABBITMQ_VERSION
RUN apk update && apk add --no-cache wget && \
    case "${RABBITMQ_VERSION%%.*}" in \
    "3") \
        case "$RABBITMQ_VERSION" in \
            3.9.*) \
                LVC_URL="https://github.com/rabbitmq/rabbitmq-lvc-exchange/releases/download/3.9.15/rabbitmq_lvc_exchange-3.9.15.ez" \
                ;; \
            3.10.*) \
                LVC_URL="https://github.com/rabbitmq/rabbitmq-lvc-exchange/releases/download/v3.10.0/rabbitmq_lvc_exchange-v3.10.x.ez" \
                ;; \
            3.11.*) \
                LVC_URL="https://github.com/rabbitmq/rabbitmq-lvc-exchange/releases/download/v3.11.4/rabbitmq_lvc_exchange-v3.11.4.ez" \
                ;; \
            3.12.*) \
                LVC_URL="https://github.com/rabbitmq/rabbitmq-lvc-exchange/releases/download/v3.12.0/rabbitmq_lvc_exchange-3.12.0.ez" \
                ;; \
            3.13.*) \
                LVC_URL="https://github.com/nbr23/rabbitmq-lvc-exchange/releases/download/v3.13/rabbitmq_lvc_exchange-v3.13.x.ez" \
                ;; \
            *) \
                echo "Unsupported RabbitMQ version: $RABBITMQ_VERSION" && exit 1 \
                ;; \
        esac \
        ;; \
    *) \
        echo "Unsupported RabbitMQ major version: $RABBITMQ_VERSION" && exit 1 \
        ;; \
    esac && \
    wget -O /rabbitmq_lvc_exchange.ez $LVC_URL


FROM rabbitmq:$RABBITMQ_VERSION-management-alpine

COPY --from=downloader /rabbitmq_lvc_exchange.ez /plugins/rabbitmq_lvc_exchange.ez

RUN rabbitmq-plugins enable --offline rabbitmq_consistent_hash_exchange rabbitmq_lvc_exchange rabbitmq_shovel rabbitmq_shovel_management
