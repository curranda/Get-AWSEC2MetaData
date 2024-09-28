function Get-AWSEC2MetaData {
    param (
        [Parameter(Position=0,mandatory=$true)]
        [string]$URL,     # Starting URL
        [string]$filter     # Filter
    )
    
    # Holder for Files
    $FileList = @()

    # Holder for captured content
    $CapturedMetaData = @()

    #http://metadata.services.cityinthe.cloud:1338/latest/meta-data
    $resultsFromURL = (Invoke-WebRequest "$URL").Content -split "`n"

    # Reading content from URL
    foreach ($NextRequest in $resultsFromURL)
    {
        # If directory then creates new URL and sends to same function
        If ($NextRequest -like "*/*")
        {           
            # Removes / to prevent duplicate //
            $NextRequest = $NextRequest -replace "/",""

            # Creates new target URL
            $SubDirectory = "$URL/$NextRequest"
                       
            # Calls same function to search for directories and files
            Get-AWSEC2MetaData $SubDirectory
        }
        else
        {
            # Adds file to list
            $FileList += "$URL/$NextRequest"              
        }
    }    

    # Loop to reach each file found
    foreach ($file in $FileList)
    {
        # Creates object for all captured metadata
        $CapturedMetaData += New-Object psobject -property @{
            URL = "$file";
            MetaData = ((Invoke-WebRequest "$file").Content).tostring() ;
        }
    }

    # Returns all captured meta data
    return $CapturedMetaData | Select-Object -Property URL, MetaData
}