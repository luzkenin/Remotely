function Test-InstalledSoftware {
    <#
	.SYNOPSIS
		This function is used as a quick check to see if a specific software product is installed on the local host.
	.PARAMETER Name
	 	The name of the software you'd like to query as displayed by the Get-InstalledSoftware function
	.PARAMETER Version
		The version of the software you'd like to query as displayed by the Get-InstalledSofware function.
	.PARAMETER Guid
		The GUID of the installed software
	#>
    [OutputType([bool])]
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName,

        [Parameter(ParameterSetName = 'Name')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(ParameterSetName = 'Name')]
        [ValidateNotNullOrEmpty()]
        [string]$Version,

        [Parameter(ParameterSetName = 'Guid')]
        [ValidateNotNullOrEmpty()]
        [Alias('ProductCode')]
        [string]$Guid
    )
    process {
        try {
            $getSoftwareParams = @{}
            if ($PSBoundParameters.ContainsKey('ComputerName')) {
                $getSoftwareParams.ComputerName = $ComputerName
            }
            if ($PSBoundParameters.ContainsKey('Name')) {
                $getSoftwareParams.Name = $Name
            }

            $whereFilter = {'*'}
            if ($PSBoundParameters.ContainsKey('Version')) {
                $whereFilter = { $_.Version -eq $Version }
            }

            if ($PSBoundParameters.ContainsKey('Guid')) {
                $getSoftwareParams.Guid = $Guid
            }

            if (-not ($SoftwareInstances = Get-InstalledSoftware @getSoftwareParams | Where-Object -FilterScript $whereFilter)) {
                Write-Log -Message 'The software is NOT installed.'
                $false
            } else {
                Write-Log -Message 'The software IS installed.'
                $true
            }
        } catch {
            Write-Log -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)" -LogLevel '3'
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}