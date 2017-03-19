package main

import (
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-sdk-go/aws/awsutil"
	"github.com/eawsy/aws-lambda-go-core/service/lambda/runtime"
	"github.com/eawsy/aws-lambda-go-event/service/lambda/runtime/event/s3evt"
	"github.com/nlopes/slack"
)

var slackAPI *slack.Client

func Handle(evt *s3evt.Event, ctx *runtime.Context) (interface{}, error) {
	for _, rec := range evt.Records {
		log.Println("ln ", rec)
		log.Printf("Event Name %s\n", rec.EventName)
		if rec.EventName == "ObjectRemoved:Delete" {
			err := sendSlack(rec)
			if err != nil {
				fmt.Printf("%s\n", err.Error())
			}
		}
	}

	return nil, nil
}

func sendSlack(evt *s3evt.EventRecord) error {
	fmt.Printf("trigger slack event")
	params := slack.PostMessageParameters{}
	channelID, timestamp, err := slackAPI.PostMessage("general", awsutil.Prettify(evt), params)
	if err != nil {
		return err
	}
	fmt.Printf("Message successfully sent to channel %s at %s", channelID, timestamp)
	return nil
}

func init() {
	slackToken := os.Getenv("slack_api_token")
	if len(slackToken) < 0 {
		fmt.Printf("%s\n", "slack API token not set")
		os.Exit(1)
	}

	slackAPI = slack.New(slackToken)
}

func main() {}
