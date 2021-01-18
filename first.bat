@echo off
(curl -u admin:Hello@1234 -i -X POST http://localhost:8082/artifactory/api/search/aql -H "Content-Type: text/plain" -d "items.find({\"type\":\"folder\",\"repo\":{\"$eq\":\"example-repo-local\"},\"path\":{\"$eq\":\"dir1\"}}).include(\"name\")" )> result.txt
type result.txt 
