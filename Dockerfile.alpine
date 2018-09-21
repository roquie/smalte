FROM nimlang/nim:0.18.0-alpine as build

WORKDIR /usr/src/app
COPY . /usr/src/app

RUN nimble install --depsOnly --accept \
    && nim c --threads:on -r tests/test1.nim \
    && nim c -d:release --threads:on --opt:size src/smalte.nim

FROM alpine:3.8
COPY --from=build /usr/src/app/src/smalte /app/smalte

RUN apk add --no-cache pcre

WORKDIR /app

CMD ["/app/smalte"]
