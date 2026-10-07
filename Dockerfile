FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN cp profiles.yml.example profiles.yml

# pass snowflake credentials at runtime: docker run --env-file .env <image>
ENTRYPOINT ["dbt"]
CMD ["build", "--profiles-dir", "."]
