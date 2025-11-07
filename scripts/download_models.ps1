<#
Linly-Talker Model Download Script for Windows
NO CHINESE = NO ENCODING ISSUES!
#>

# Step 1: Select Download Method (English Only)
Write-Host "======================================"
Write-Host "Model Download Method"
Write-Host "1. ModelScope (Recommended)"
Write-Host "   - Requirement: pip install modelscope"
Write-Host "2. Huggingface (With resume support)"
Write-Host "3. Huggingface Mirror (Faster in China)"
Write-Host "======================================"
$download_option = Read-Host "Please enter 1, 2, or 3"

# Step 2: Download Models
try {
    if ($download_option -eq 1) {
        Write-Host "`nDownloading from ModelScope..."
        python scripts/modelscope_download.py
        if ($LASTEXITCODE -ne 0) { throw "ModelScope download failed! Check script or network." }
    }
    elseif ($download_option -eq 2) {
        Write-Host "`nDownloading from Huggingface..."
        python scripts/huggingface_download.py
        if ($LASTEXITCODE -ne 0) { throw "Huggingface download failed! Check script or network." }
    }
    elseif ($download_option -eq 3) {
        Write-Host "`nDownloading from Huggingface Mirror (hf-mirror.com)..."
        $env:HF_ENDPOINT = "https://hf-mirror.com"
        # Install huggingface-hub if missing
        if (-not (Get-Command "huggingface-cli" -ErrorAction SilentlyContinue)) {
            Write-Host "Installing required package: huggingface-hub..."
            pip install huggingface-hub -i https://pypi.tuna.tsinghua.edu.cn/simple
        }
        # Start download
        huggingface-cli download --resume-download --local-dir-use-symlinks False Kedreamix/Linly-Talker --local-dir Linly-Talker
        if ($LASTEXITCODE -ne 0) { throw "Mirror download failed! Check network connection." }
    }
    else {
        throw "Invalid input! Only 1, 2, or 3 is allowed."
    }

    Write-Host "`nDownload completed successfully! Starting to organize models..."

    # Step 3: Organize Model Files
    $source_dir = "Kedreamix\Linly-Talker"
    # Fix for Method 3: source dir is "Linly-Talker"
    if (-not (Test-Path $source_dir) -and (Test-Path "Linly-Talker")) {
        $source_dir = "Linly-Talker"
    }
    $checkpoints_dst = ".\checkpoints"

    # 3.1 Move checkpoints
    if (Test-Path "$source_dir\checkpoints") {
        if (-not (Test-Path $checkpoints_dst)) { New-Item -ItemType Directory -Path $checkpoints_dst | Out-Null }
        Move-Item "$source_dir\checkpoints\*" $checkpoints_dst -Force
        Write-Host "✅ Checkpoints moved to $checkpoints_dst"
    }
    else { throw "❌ Missing directory: $source_dir\checkpoints" }

    # 3.2 Move gfpgan
    if (Test-Path "$source_dir\gfpgan") {
        Move-Item "$source_dir\gfpgan" .\gfpgan -Force
        Write-Host "✅ GFPGAN moved to .\gfpgan"
    }
    else { throw "❌ Missing directory: $source_dir\gfpgan" }

    # 3.3 Move GPT_SoVITS
    $gpt_sovits_src = "$source_dir\GPT_SoVITS\pretrained_models"
    $gpt_sovits_dst = ".\GPT_SoVITS\pretrained_models"
    if (Test-Path $gpt_sovits_src) {
        if (-not (Test-Path $gpt_sovits_dst)) { New-Item -ItemType Directory -Path $gpt_sovits_dst -Force | Out-Null }
        Move-Item "$gpt_sovits_src\*" $gpt_sovits_dst -Force
        Write-Host "✅ GPT_SoVITS models moved to $gpt_sovits_dst"
    }
    else { throw "❌ Missing directory: $gpt_sovits_src" }

    # 3.4 Move Qwen
    if (Test-Path "$source_dir\Qwen") {
        Move-Item "$source_dir\Qwen" .\Qwen -Force
        Write-Host "✅ Qwen model moved to .\Qwen"
    }
    else { throw "❌ Missing directory: $source_dir\Qwen" }

    # 3.5 Move MuseTalk
    $musetalk_src = "$source_dir\MuseTalk"
    $musetalk_dst = ".\Musetalk\models"
    if (Test-Path $musetalk_src) {
        if (-not (Test-Path $musetalk_dst)) { New-Item -ItemType Directory -Path $musetalk_dst -Force | Out-Null }
        Move-Item "$musetalk_src\*" $musetalk_dst -Force
        Write-Host "✅ MuseTalk models moved to $musetalk_dst"
    }
    else { throw "❌ Missing directory: $musetalk_src" }

    # 3.6 Move Whisper
    if (Test-Path "$source_dir\Whisper") {
        Move-Item "$source_dir\Whisper" .\Whisper -Force
        Write-Host "✅ Whisper model moved to .\Whisper"
    }
    else { throw "❌ Missing directory: $source_dir\Whisper" }

    # 3.7 Move FunASR
    if (Test-Path "$source_dir\FunASR") {
        Move-Item "$source_dir\FunASR" .\FunASR -Force
        Write-Host "✅ FunASR model moved to .\FunASR"
    }
    else { throw "❌ Missing directory: $source_dir\FunASR" }

    # 3.8 Process CosyVoice (Fix: Index out of bounds)
    $cosyvoice_src = "$checkpoints_dst\CosyVoice_ckpt\CosyVoice-ttsfrd"
    $cosyvoice_dst = ".\CosyVoice\pretrained_models"
    if (Test-Path $cosyvoice_src) {
        if (-not (Test-Path $cosyvoice_dst)) { New-Item -ItemType Directory -Path $cosyvoice_dst -Force | Out-Null }
        Move-Item $cosyvoice_src $cosyvoice_dst -Force
        # Unzip resource.zip if exists
        $zip_file = "$cosyvoice_dst\CosyVoice-ttsfrd\resource.zip"
        if (Test-Path $zip_file) {
            Expand-Archive $zip_file -DestinationPath "$cosyvoice_dst\CosyVoice-ttsfrd" -Force
            Write-Host "✅ CosyVoice resource.zip unzipped"
        }
        # Install whl only if exists
        $whl_files = Get-ChildItem "$cosyvoice_dst\CosyVoice-ttsfrd" -Filter "ttsfrd-*.whl" -ErrorAction SilentlyContinue
        if ($whl_files) {
            $whl_file = $whl_files[0]
            pip install $whl_file.FullName -i https://pypi.tuna.tsinghua.edu.cn/simple
            Write-Host "✅ CosyVoice ttsfrd installed"
        }
        else {
            Write-Host "⚠️ No ttsfrd whl file found, skip installation"
        }
        Write-Host "✅ CosyVoice processed successfully"
    }
    else {
        Write-Host "⚠️ CosyVoice source directory missing: $cosyvoice_src, skip processing"
    }

    # Final Message
    Write-Host "`n======================================"
    Write-Host "🎉 All models are ready! Enjoy Linly-Talker!"
    Write-Host "======================================"
}
catch {
    Write-Host "`n❌ Error: $_" -ForegroundColor Red
    exit 1
}