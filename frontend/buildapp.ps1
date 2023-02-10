
param([string]$apiurl,[string]$containertag)
#Add the URL to the API
# ------------------------- #
flutter build web --dart-define=API_URL=$apiurl
# ------------------------- #

#Then build the Dockerfile
# ------------------------- #
docker build -t $containertag .
# ------------------------- #