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

# Constantes pour la disposition
$maxRows = 4
$columnWidth = 100  # Largeur de chaque colonne
$startX = 10        # Position de départ pour la première colonne
$startY = 30        # Position de départ pour la première ligne

# Tableau pour stocker les CheckBox
$checkBoxes = @()

# Chemin de l'exécutable choisi
$execPathFile = ""

# Ajout des CheckBox
for ($i = 0; $i -lt [Environment]::ProcessorCount; $i++) {
    $checkBox = New-Object System.Windows.Forms.CheckBox
    $checkBox.Text = "Core $i"
    # Calcul de la position en fonction de l'index
    $columnIndex = [math]::Floor($i / $maxRows)
    $rowIndex = $i % $maxRows
    $checkBox.Location = [System.Drawing.Point]::new($startX + $columnWidth * $columnIndex, $startY + $rowIndex * 20)
    $checkBox.AutoSize = $true
    $mainForm.Controls.Add($checkBox)
    $checkBoxes += $checkBox
}

# Fonction pour obtenir la valeur binaire en fonction des CheckBox sélectionnées
function Get-CoreSelectionBinaryValue {
    $binaryValue = 0
    for ($i = 0; $i -lt $checkBoxes.Count; $i++) {
        if ($checkBoxes[$i].Checked) {
            # Utilisation de l'opération binaire OR pour définir le bit correspondant
            $binaryValue = $binaryValue -bor (1 -shl $i)
        }
    }
    return $binaryValue
}

# Créer un bouton pour ouvrir la boîte de dialogue de sélection de fichier
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = [System.Drawing.Point]::new(10, $startY + ($maxRows * 20) + 10)
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

# Ajouter un label pour afficher le chemin du fichier sélectionné
$selectedFileLabel = New-Object System.Windows.Forms.Label
$selectedFileLabel.Location =  [System.Drawing.Point]::new(100, $startY + ($maxRows * 20) + 15)
$selectedFileLabel.AutoSize = $true
$mainForm.Controls.Add($selectedFileLabel)

# Bouton pour obtenir le résultat
$button = New-Object System.Windows.Forms.Button
$button.Text = "Launch"
$button.Location = [System.Drawing.Point]::new(10, $startY + ($maxRows * 20) + 50)
$button.AutoSize = $true
$button.Add_Click({
    if ($global:execPathFile -ne "") {
        $anyChecked = $checkBoxes | ForEach-Object { $_.Checked } | Where-Object { $_ -eq $true }
        if ($anyChecked) {
            $binaryValue = Get-CoreSelectionBinaryValue
            $process = Start-Process -FilePath $execPathFile -PassThru
            Start-Sleep -Seconds 5
            $process.ProcessorAffinity = $binaryValue
            $mainForm.Close()
            [System.Windows.Forms.Application]::Exit()
        } else {
            [System.Windows.Forms.MessageBox]::Show("Please select at least one core.")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please select an executable file.")
    }
})
$mainForm.Controls.Add($button)

$mainForm.ShowDialog() | Out-Null
