FROM dory.pressrelations.de:5000/base-elixir-1.3:1.3.2-1

WORKDIR /app

RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

# COPY mix.* ./
# RUN mix deps.get && \
# 	mix deps.compile && \
# 	mix compile && \
# 	MIX_ENV=prod mix compile

# COPY lib ./lib
# COPY web ./web
# # COPY spec ./spec
# COPY config ./config

# RUN mix compile && \
# 	MIX_ENV=prod mix compile

# # COPY service/ /etc/service/

# ENV PORT 4000
# ENV READ_SECRETS_FROM_VAULT true
# EXPOSE 4000
