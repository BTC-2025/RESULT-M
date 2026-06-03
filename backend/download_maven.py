import os
import urllib.request
import zipfile

maven_url = "https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip"
zip_path = "maven.zip"
extract_path = "."

print("Downloading Apache Maven 3.9.6...")
urllib.request.urlretrieve(maven_url, zip_path)
print("Download complete. Extracting...")

with zipfile.ZipFile(zip_path, 'r') as zip_ref:
    zip_ref.extractall(extract_path)

print("Extraction complete. Cleaning up zip file...")
os.remove(zip_path)
print("Maven is ready at ./apache-maven-3.9.6/bin/mvn")
