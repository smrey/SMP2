			# Wait for the app to complete and store the appsession ID	
			appRes=$(bs -c "$CONFIG" wait "$appSessionId" --terse)

			echo "Downloading files for ""$pair"		

			# Download required analysis results files
			bs cp conf://"$CONFIG"/Projects/"$projectId"/appresults/"$appRes"/*.bam "$RESULTSFOLDER"
			bs cp conf://"$CONFIG"/Projects/"$projectId"/appresults/"$appRes"/*.bai "$RESULTSFOLDER"
			bs cp conf://"$CONFIG"/Projects/"$projectId"/appresults/"$appRes"/*.xls* "$RESULTSFOLDER"