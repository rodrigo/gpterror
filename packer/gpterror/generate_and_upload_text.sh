#!/bin/bash

file_count=$(aws s3 ls s3://rebelatto/gpterror/stories --recursive | wc -l)
if [ $file_count -lt 99 ]; then
  generated_text=$(curl https://api.openai.com/v1/chat/completions -s \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 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" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "create a fictional horror story choosing randonly two of this themes: demons, ghosts, witches, pychos, madness, cosmic horror, dystopic futures, killer robots, cybernetic treats, biological treats, apocalypse or serial killers. The story must have at least one thousand words."}],
    "temperature": 0.7
  }' | python3 -c 'import sys, json; print(json.load(sys.stdin)["choices"][0]["message"]["content"])')

  echo $generated_text > /tmp/file.txt
  aws s3api put-object --bucket rebelatto --key gpterror/stories/file$(date +"%s").txt --body /tmp/file.txt
  rm /tmp/file.txt
fi
aws cloudwatch put-metric-data --region us-east-1 --namespace gpterror \
  --metric-data '{"MetricName":"s3-objects-count", "Value": '$file_count', "Unit": "Count"}'
