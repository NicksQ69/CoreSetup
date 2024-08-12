Add-Type -AssemblyName System.Windows.Forms

$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = 'CoreSetup - by nicks_ch'
$mainForm.Width = 600
$mainForm.Height = 400
$mainForm.AutoSize = $true

$labelCore = New-Object System.Windows.Forms.Label
$labelCore.Text = "Available Cores : " + ([Environment]::ProcessorCount).ToString()
$labelCore.Location = New-Object System.Drawing.Point(10,10)
$labelCore.AutoSize = $true
$mainForm.Controls.Add($labelCore)

# Layout constants
$maxRows = 4
$columnWidth = 100  # Width of each column
$startX = 10        # Starting position for first column
$startY = 30        # Starting position for the first line

$priorityValue = @{
    "Below Normal" = 16384;
    "Normal" = 32;
    "Above Normal" = 32768;
    "High Priority" = 128;
    "Realtime" = 256;
}

# Table for storing CheckBoxes
$checkBoxes = @()

# Path of selected executable
$execPathFile = ""

for ($i = 0; $i -lt [Environment]::ProcessorCount; $i++) {
    $checkBox = New-Object System.Windows.Forms.CheckBox
    $checkBox.Text = "Core $i"
    # Position calculation based on index
    $columnIndex = [math]::Floor($i / $maxRows)
    $rowIndex = $i % $maxRows
    $checkBox.Location = [System.Drawing.Point]::new($startX + $columnWidth * $columnIndex, $startY + $rowIndex * 20)
    $checkBox.AutoSize = $true
    $mainForm.Controls.Add($checkBox)
    $checkBoxes += $checkBox
}

# Function to obtain the binary value according to the selected CheckBoxes
function Get-CoreSelectionBinaryValue {
    $binaryValue = 0
    for ($i = 0; $i -lt $checkBoxes.Count; $i++) {
        if ($checkBoxes[$i].Checked) {
            # Use the OR binary operation to define the corresponding bit
            $binaryValue = $binaryValue -bor (1 -shl $i)
        }
    }
    return $binaryValue
}

$boxLabel = New-Object System.Windows.Forms.Label
$boxLabel.Text = "Set priority value :"
$boxLabel.Location = [System.Drawing.Point]::new(10, $startY + ($maxRows * 20) + 12)
$boxLabel.AutoSize = $true
$mainForm.Controls.Add($boxLabel)

$ComboBox = New-Object System.Windows.Forms.ComboBox
$ComboBox.Width = 100
foreach ($priority in $priorityValue.keys) {
    $ComboBox.Items.Add($priority) | Out-Null;
}
$ComboBox.Location = [System.Drawing.Point]::new(105, $startY + ($maxRows * 20) + 10)
$comboBox.SelectedIndex = 4
$mainForm.Controls.Add($ComboBox)

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = [System.Drawing.Point]::new(10, $startY + ($maxRows * 20) + 40)
$browseButton.AutoSize = $true
$browseButton.Text = 'Browse...'
$browseButton.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Executable (*.exe)|*.exe"
    $openFileDialog.InitialDirectory = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyComputer)
    
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedFileLabel.Text = $openFileDialog.FileName
        $global:execPathFile = $openFileDialog.FileName
    }
})
$mainForm.Controls.Add($browseButton)

$selectedFileLabel = New-Object System.Windows.Forms.Label
$selectedFileLabel.Location =  [System.Drawing.Point]::new(100, $startY + ($maxRows * 20) + 45)
$selectedFileLabel.AutoSize = $true
$mainForm.Controls.Add($selectedFileLabel)

$button = New-Object System.Windows.Forms.Button
$button.Text = "Launch"
$button.Location = [System.Drawing.Point]::new(10, $startY + ($maxRows * 20) + 78)
$button.AutoSize = $true
$button.Add_Click({
    if ($global:execPathFile -ne "") {
        $anyChecked = $checkBoxes | ForEach-Object { $_.Checked } | Where-Object { $_ -eq $true }
        if ($anyChecked) {
            if ($ComboBox.SelectedItem -ne $null) {
                $binaryValue = Get-CoreSelectionBinaryValue
                $process = Start-Process -FilePath $execPathFile -PassThru
                Start-Sleep -Seconds 5
                $process.PriorityClass = $priorityValue[$ComboBox.SelectedItem]
                $process.ProcessorAffinity = $binaryValue
                $mainForm.Close()
                [System.Windows.Forms.Application]::Exit()
            } else {
                [System.Windows.Forms.MessageBox]::Show("Please select a priority value.")
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("Please select at least one core.")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please select an executable file.")
    }
})
$mainForm.Controls.Add($button)

$mainForm.ShowDialog() | Out-Null
