FROM nimlang/nim:1.6.6-alpine-onbuild

# install timezones database
RUN apk add tzdata 
# set timezone to Iran
RUN cp /usr/share/zoneinfo/Iran /etc/localtime

# prepare app
WORKDIR /app
COPY . /app/

RUN nimble go
CMD ["./bin.exe"]