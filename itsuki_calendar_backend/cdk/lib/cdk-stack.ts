import { join } from 'path';
import { RustFunction } from 'cargo-lambda-cdk';
import { EndpointType, LambdaRestApi } from 'aws-cdk-lib/aws-apigateway'
import { RemovalPolicy, Stack, StackProps } from "aws-cdk-lib";
import { Construct } from "constructs";


export class CdkStack extends Stack {
    private databaseUrl = "postgres://username:password@127.0.0.1/itsuki_calendar"

    constructor(scope: Construct, id: string, props?: StackProps) {
        super(scope, id, props);

        const lmabdaHandler = new RustFunction(this, 'ItsukiCalendarLambda', {
            manifestPath: join(__dirname, '..', '..'),
            environment: {
                "DATABASE_URL": this.databaseUrl
            }
        });
        lmabdaHandler.applyRemovalPolicy(RemovalPolicy.DESTROY)


        const restApi = new LambdaRestApi(this, 'ItsukiCalendarRestAPI', {
            handler: lmabdaHandler,
            endpointTypes: [EndpointType.REGIONAL]
        });

        restApi.applyRemovalPolicy(RemovalPolicy.DESTROY)
    }
}