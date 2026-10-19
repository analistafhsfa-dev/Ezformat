# ============================================================
# EzFormat
# Criado por Guilherme - Analista Infra Seg
#
# ============================================================
# ============================================================
# UTF-8 - Forçar codificação com acentos e caracteres
# ============================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
# ============================================================
# ADMINISTRADOR - Forçar pedir credenciais ao iniciar
# ============================================================
$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal(
    $currentIdentity
)
if (-not $principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)) {
    Start-Process `
        -FilePath "powershell.exe" `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}
# ============================================================
# CONFIGURAÇÕES BASICAS
# ============================================================
#Continuar mesmo apresentando erro
$ErrorActionPreference = "SilentlyContinue"
#DominioFHSFA
$DomainName = "fhsfaucc.org"
#Credencial se necessario
$AdminPassword = "290535"
#ServFiles
$FileServer = "\\10.0.0.233"
#User
$FileServerUser = "fhsfaucc\public"
#Key
$FileServerPassword = "123"
#VAR ServPublic
$Publico = "$FileServer\publico"
#Caminho Copy GesthosUCC
$GesthosSource = "$Publico\Programas Basicos\Gesthos & Firebird\gesthos_ucc"
#Caminho Destino
$GesthosDestination = "C:\Gesthos"
#Caminho Copy Firebird
$FirebirdInstaller = "C:\temp\Firebird2.exe"
#Caminho Executavel Gesthos
$GesthosExe = "C:\Gesthos\GestHos.exe"
#Destino Executavel Desktop
$GesthosShortcut = "$env:Public\Desktop\Gesthos.lnk"
# ============================================================
# PERSONALIZAÇÃO - BOTOES
# ============================================================
# Lista de ordem dos botoes
# ============================================================
$ButtonOrder = @(
    "ADMIN"
	"FIREWALL"
	"RDP"	
	"ENERGIA"
	"PASTAS"
	"GESTHOS"
	"FIREBIRD"
	"7ZIP"
	"CHROME"
	"VNC"
	"OFFICE"
	"DOMINIO"
	"BIOS"
    "PRINT"
	"OTIMIZACAO"
	"UPDATE"   
)
# ============================================================
# Remove e ADD novamente KEY SERVPUBLIC 
# ============================================================
cmdkey.exe /delete:10.0.0.233 2>$null
cmdkey.exe `
    /add:10.0.0.233 `
    /user:$FileServerUser `
    /pass:$FileServerPassword |
    Out-Null
# ============================================================
# WPF - Bibliotecas basicas para funcionamento
# ============================================================
#LOAD componentes de janelas, botoes e interface
Add-Type -AssemblyName PresentationFramework
#LOAD recursos graficos, imagens, textos e render
Add-Type -AssemblyName PresentationCore
#LOAD Propriedades, eventos e temporizadores
Add-Type -AssemblyName WindowsBase
#LOAD Windows Forms, caixa de dialogos, seletores de arquivos
Add-Type -AssemblyName System.Windows.Forms
# ============================================================
# XAML - Interface
# ============================================================
[xml]$Xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="EzFormat"
	Width="800"
	Height="650"
	MinWidth="650"
	MinHeight="500"
	WindowStartupLocation="CenterScreen"
	SizeToContent="Manual"
	ResizeMode="CanResize"
	Background="#F4F6F8"
	FontFamily="Segoe UI">

    <Window.Resources>
        <!-- ================================================= -->
        <!-- GRADIENTE DOS BOTÕES - Branco e AZUL              -->
        <!-- ================================================= -->

        <LinearGradientBrush x:Key="ButtonGradient" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#FFFFFF" Offset="0"/>
            <GradientStop Color="#EAF5FF" Offset="0.55"/>
            <GradientStop Color="#CFE8FF" Offset="1"/>
        </LinearGradientBrush>

        <!-- ================================================= -->
        <!-- BOTÃO PRINCIPAL - UNICO                           -->
        <!-- ================================================= -->

        <Style x:Key="MenuButton" TargetType="Button">

            <Setter Property="Height" Value="48"/>
            <Setter Property="Margin" Value="7"/>
            <Setter Property="Padding" Value="8,0"/>
            <Setter Property="FontSize" Value="10"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Foreground" Value="#243447"/>
            <Setter Property="Background" Value="{StaticResource ButtonGradient}"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>

            <Setter Property="Template">

                <Setter.Value>

                    <ControlTemplate TargetType="Button">

                        <Border
                            x:Name="Border"
                            Background="{TemplateBinding Background}"
                            CornerRadius="9"
                            BorderThickness="1"
                            BorderBrush="#C9D6E2">

                            <Grid>

                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="42"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>

                                <Border
                                    Grid.Column="0"
                                    Background="Transparent"
                                    CornerRadius="9,0,0,9">

                                    <TextBlock
                                        x:Name="Led"
                                        Text="●"
                                        FontSize="20"
                                        HorizontalAlignment="Center"
                                        VerticalAlignment="Center"
                                        Foreground="#C62828"/>

                                </Border>

                                <ContentPresenter
                                    Grid.Column="1"
                                    VerticalAlignment="Center"
                                    HorizontalAlignment="Left"
                                    Margin="8,0,0,0"/>

                            </Grid>

                        </Border>

                        <ControlTemplate.Triggers>

                            <Trigger Property="IsMouseOver" Value="True">

                                <Setter
                                    TargetName="Border"
                                    Property="Opacity"
                                    Value="0.88"/>

                            </Trigger>

                            <Trigger Property="IsPressed" Value="True">

                                <Setter
                                    TargetName="Border"
                                    Property="Opacity"
                                    Value="0.72"/>

                            </Trigger>

                            <Trigger Property="IsEnabled" Value="False">

                                <Setter
                                    TargetName="Border"
                                    Property="Opacity"
                                    Value="0.55"/>

                            </Trigger>

                        </ControlTemplate.Triggers>

                    </ControlTemplate>

                </Setter.Value>

            </Setter>

        </Style>


        <!-- ================================================= -->
        <!-- LED INFORMATIVO / CINZA                         -->
        <!-- ================================================= -->

        <Style
            x:Key="InformativeButton"
            TargetType="Button"
            BasedOn="{StaticResource MenuButton}">

            <Setter Property="Background" Value="{StaticResource ButtonGradient}"/>
            <Setter Property="Foreground" Value="#243447"/>

        </Style>


        <!-- ================================================= -->
        <!-- CARD                                              -->
        <!-- ================================================= -->

        <Style x:Key="CardStyle" TargetType="Border">

            <Setter Property="Background" Value="#FFFFFF"/>
            <Setter Property="CornerRadius" Value="12"/>
            <Setter Property="BorderBrush" Value="#E1E5E9"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="18"/>

        </Style>


        <!-- ================================================= -->
        <!-- TEXTO DE TÍTULO                                   -->
        <!-- ================================================= -->

        <Style x:Key="TitleText" TargetType="TextBlock">

            <Setter Property="FontFamily" Value="Segoe UI"/>
            <Setter Property="FontSize" Value="22"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Foreground" Value="#202428"/>

        </Style>


        <!-- ================================================= -->
        <!-- TEXTO SECUNDÁRIO                                  -->
        <!-- ================================================= -->

        <Style x:Key="SecondaryText" TargetType="TextBlock">

            <Setter Property="FontFamily" Value="Segoe UI"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Foreground" Value="#707780"/>

        </Style>

    </Window.Resources>


    <!-- ===================================================== -->
    <!-- ESTRUTURA PRINCIPAL                                  -->
    <!-- ===================================================== -->

    <Grid>

        <Grid.RowDefinitions>

            <RowDefinition Height="82"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="42"/>

        </Grid.RowDefinitions>


        <!-- ================================================= -->
        <!-- CABEÇALHO - TITULO                                -->
        <!-- ================================================= -->

        <Border
            Grid.Row="0"
            Background="#FFFFFF"
            BorderBrush="#E1E5E9"
            BorderThickness="0,0,0,1">

            <Grid Margin="28,0">

                <Grid.ColumnDefinitions>

                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>

                </Grid.ColumnDefinitions>


                <StackPanel
                    Grid.Column="0"
                    VerticalAlignment="Center">

                    <TextBlock
                        Text="⚒  EzFormat"
                        Style="{StaticResource TitleText}"/>

                    <TextBlock
                        Text="Painel de configuração Windows - FHSFA"
                        Style="{StaticResource SecondaryText}"
                        Margin="1,3,0,0"/>

                </StackPanel>


                <Border
                    Grid.Column="1"
                    Background="#F1F3F5"
                    CornerRadius="8"
                    Padding="14,7"
                    VerticalAlignment="Center">

                    <StackPanel>

                        <TextBlock
                            Text="COMPUTADOR"
                            FontSize="10"
                            FontWeight="SemiBold"
                            Foreground="#858C94"
                            HorizontalAlignment="Center"/>

                        <TextBlock
                            x:Name="TxtComputer"
                            Text="COMPUTADOR"
                            FontSize="13"
                            FontWeight="SemiBold"
                            Foreground="#343A40"
                            HorizontalAlignment="Center"
                            Margin="0,2,0,0"/>

                    </StackPanel>

                </Border>

            </Grid>

        </Border>


        <!-- ================================================= -->
        <!-- ÁREA CENTRAL                                      -->
        <!-- ================================================= -->

        <Grid
            Grid.Row="1"
            Margin="22,20,22,18">

            <Grid.ColumnDefinitions>

                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="300"/>

            </Grid.ColumnDefinitions>


            <!-- ============================================= -->
            <!-- ÁREA DOS BOTÕES                               -->
            <!-- ============================================= -->

            <Border
                Grid.Column="0"
                Style="{StaticResource CardStyle}"
                Margin="0,0,10,0">

                <Grid>

                    <Grid.RowDefinitions>

                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>

                    </Grid.RowDefinitions>


                    <StackPanel Grid.Row="0">

                        <TextBlock
                            Text="Funções"
                            FontSize="18"
                            FontWeight="SemiBold"
                            Foreground="#25292D"/>

                        <TextBlock
                            Text="Selecione a opção. (Botões com * devem ser realizados no usuario Administrador.)"
                            Style="{StaticResource SecondaryText}"
                            Margin="0,4,0,12"/>

                    </StackPanel>


                    <ScrollViewer
                        Grid.Row="1"
                        VerticalScrollBarVisibility="Auto"
                        HorizontalScrollBarVisibility="Disabled">

                        <UniformGrid
                            x:Name="ButtonsPanel"
                            Columns="2"/>

                    </ScrollViewer>

                </Grid>

            </Border>


            <!-- ============================================= -->
            <!-- PAINEL LATERAL                                -->
            <!-- ============================================= -->

            <StackPanel
                Grid.Column="1"
                Margin="10,0,0,0">


                <!-- ========================================= -->
                <!-- STATUS                                     -->
                <!-- ========================================= -->

                <Border
                    Style="{StaticResource CardStyle}"
                    Margin="0,0,0,12">

                    <StackPanel>

                        <TextBlock
                            Text="Status"
                            FontSize="17"
                            FontWeight="SemiBold"
                            Foreground="#25292D"/>

                        <TextBlock
                            Text="Acompanhamento da configuração"
                            Style="{StaticResource SecondaryText}"
                            Margin="0,3,0,16"/>


                        <Border
                            Background="#F4F6F8"
                            CornerRadius="8"
                            Padding="12">

                            <StackPanel>

                                <TextBlock
                                    x:Name="TxtStatus"
                                    Text="Status: Pronto"
                                    FontSize="15"
                                    FontWeight="SemiBold"
                                    Foreground="#343A40"/>

                                <ProgressBar
                                    x:Name="ProgressStatus"
                                    Height="8"
                                    Minimum="0"
                                    Maximum="100"
                                    Value="0"
                                    Margin="0,12,0,0"/>

                                <TextBlock
                                    x:Name="TxtProgress"
                                    Text="0 de 11 concluídos"
                                    FontSize="12"
                                    Foreground="#777E86"
                                    Margin="0,7,0,0"/>

                            </StackPanel>

                        </Border>

                    </StackPanel>

                </Border>


                <!-- ========================================= -->
                <!-- LEGENDA                                    -->
                <!-- ========================================= -->

                <Border
                    Style="{StaticResource CardStyle}"
                    Margin="0,0,0,12">

                    <StackPanel>

                        <TextBlock
                            Text="Legenda"
                            FontSize="17"
                            FontWeight="SemiBold"
                            Foreground="#25292D"
                            Margin="0,0,0,14"/>


                        <StackPanel
                            Orientation="Horizontal"
                            Margin="0,0,0,10">

                            <Border
                                Width="14"
                                Height="14"
                                CornerRadius="4"
                                Background="#C62828"
                                Margin="0,0,10,0"/>

                            <TextBlock
                                Text="Pendente (LED vermelho)"
                                FontSize="13"
                                Foreground="#555B61"/>

                        </StackPanel>


                        <StackPanel
                            Orientation="Horizontal"
                            Margin="0,0,0,10">

                            <Border
                                Width="14"
                                Height="14"
                                CornerRadius="4"
                                Background="#198754"
                                Margin="0,0,10,0"/>

                            <TextBlock
                                Text="Concluído (LED verde)"
                                FontSize="13"
                                Foreground="#555B61"/>

                        </StackPanel>


                        <StackPanel
                            Orientation="Horizontal">

                            <Border
                                Width="14"
                                Height="14"
                                CornerRadius="4"
                                Background="#8A9199"
                                Margin="0,0,10,0"/>

                            <TextBlock
                                Text="Informativo (LED cinza)"
                                FontSize="13"
                                Foreground="#555B61"/>

                        </StackPanel>

                    </StackPanel>

                </Border>


                <!-- ========================================= -->
                <!-- INFORMAÇÕES                                -->
                <!-- ========================================= -->

                <Border
                    Style="{StaticResource CardStyle}">

                    <StackPanel>

                        <TextBlock
                            Text="Informações"
                            FontSize="17"
                            FontWeight="SemiBold"
                            Foreground="#25292D"
                            Margin="0,0,0,12"/>


                        <TextBlock
                            Text="Domínio"
                            FontSize="11"
                            Foreground="#858C94"/>

                        <TextBlock
                            x:Name="TxtDomain"
                            Text="fhsfaucc.org"
                            FontSize="13"
                            FontWeight="SemiBold"
                            Foreground="#343A40"
                            Margin="0,2,0,10"/>


                    </StackPanel>

                </Border>

            </StackPanel>

        </Grid>


        <!-- ================================================= -->
        <!-- RODAPÉ                                            -->
        <!-- ================================================= -->

        <Border
            Grid.Row="2"
            Background="#FFFFFF"
            BorderBrush="#E1E5E9"
            BorderThickness="0,1,0,0">

            <Grid Margin="22,0">

                <TextBlock
                    Text="Monitoramento ativo"
                    VerticalAlignment="Center"
                    FontSize="12"
                    Foreground="#737A82"/>

                <TextBlock
                    Text="EzFormat v3.4 | Desenvolvido por Guilherme - Analista Infra Seg"
                    HorizontalAlignment="Right"
                    VerticalAlignment="Center"
                    FontSize="12"
                    Foreground="#737A82"/>

            </Grid>

        </Border>

    </Grid>

</Window>
"@

# ============================================================
# CARREGAR JANELA - Força abrir o XAML ACIMA 
# ============================================================
$Reader = New-Object System.Xml.XmlNodeReader $Xaml
$Window = [Windows.Markup.XamlReader]::Load($Reader)
# ============================================================
# ELEMENTOS DA INTERFACE - Carrega recursos listados no XAML
# ============================================================
$TxtComputer = $Window.FindName("TxtComputer")
$TxtDomain = $Window.FindName("TxtDomain")
$TxtStatus = $Window.FindName("TxtStatus")
$TxtProgress = $Window.FindName("TxtProgress")
$ProgressStatus = $Window.FindName("ProgressStatus")
$ButtonsPanel = $Window.FindName("ButtonsPanel")
# ============================================================
# INFORMAÇÕES DO PC 
# ============================================================
$TxtComputer.Text = $env:COMPUTERNAME
$TxtDomain.Text = $DomainName
# ============================================================
# BOTÕES - Nome, TAG e Legenda ao passar o mouse sobre.
# ============================================================
$Buttons = @{}
foreach ($Name in $ButtonOrder) {
    $Button = New-Object System.Windows.Controls.Button

    switch ($Name) {
        "BIOS" {
            $Button.Content = "BIOS / CONF.SENHA"
            $Button.Tag = "BIOS"
			$Button.ToolTip = "Reinicia o computador para acessar as configurações da BIOS/UEFI."
        }
        "ADMIN" {
            $Button.Content = "ADMIN *"
            $Button.Tag = "ADMIN"
			$Button.ToolTip = "Habilita a conta Administrador local, deleta usuarios padrões e configura a senha da TI."
        }
        "FIREWALL" {
            $Button.Content = "FIREWALL *"
            $Button.Tag = "FIREWALL"
			$Button.ToolTip = "DESABILITA O FIREWALL, USAR APOS INGRESSAR NO DOMINIO."
        }
        "DOMINIO" {
            $Button.Content = "DOMÍNIO *"
            $Button.Tag = "DOMINIO"
			$Button.ToolTip = "Solicita um nome para ingressar no dominio, exige credenciais e restart."
        }
		"CHROME" {
            $Button.Content = "CHROME"
            $Button.Tag = "CHROME"
			$Button.ToolTip = "Instala o Google Chrome via MSI."
        }
        "PASTAS" {
            $Button.Content = "PASTAS *"
            $Button.Tag = "PASTAS"
			$Button.ToolTip = "Cria C:\Temp e C:\Gesthos e concede Controle Total para todos."
        }
        "RDP" {
            $Button.Content = "RDP *"
            $Button.Tag = "RDP"
			$Button.ToolTip = "Abre as configurações do Windows para habilitação da Área de Trabalho Remota."
        }
        "UPDATE" {
            $Button.Content = "WINDOWS UPDATE"
            $Button.Tag = "UPDATE"
			$Button.ToolTip = "Abre as configurações do Windows para verificar atualizações."
        }
        "OFFICE" {
            $Button.Content = "OFFICE *"
            $Button.Tag = "OFFICE"
			$Button.ToolTip = "Abre o compartilhamento de instalação do Office e Microsoft Visual C++ 2015-2022 Redistributable."
        }
        "FIREBIRD" {

            $Button.Content = "FIREBIRD *"
            $Button.Tag = "FIREBIRD"
			$Button.ToolTip = "Executa o instalador do Firebird 2.5.7."
        }
        "GESTHOS" {
            $Button.Content = "GESTHOS"
            $Button.Tag = "GESTHOS"
			$Button.ToolTip = "Copia o Gesthos para C:\Gesthos e cria o atalho na Área de Trabalho Pública."
        }
        "ENERGIA" {
            $Button.Content = "ENERGIA *"
            $Button.Tag = "ENERGIA"
			$Button.ToolTip = "Configura e força o plano de energia Alto Desempenho."
        }
        "VNC" {
            $Button.Content = "VNC *"
            $Button.Tag = "VNC"
			$Button.ToolTip = "Busca VNC via WinGet, instala e configura senha padrão, inicia o servico."
        }
        "PRINT" {
            $Button.Content = "IMPRESSÃO"
            $Button.Tag = "PRINT"
			$Button.ToolTip = "Acessa o servidor de impressão 10.0.0.206. MAQUINA DEVE ESTAR NO DOMINIO fhsfaucc.org E LOGADA NO USUARIO DO SETOR CORRESPONDENTE. "
        }
        "7ZIP" {
            $Button.Content = "7-ZIP"
            $Button.Tag = "7ZIP"
            $Button.ToolTip = "Instala o 7-Zip via Winget."
        }
        "OTIMIZACAO" {
            $Button.Content = "OTIMIZAÇÃO"
            $Button.Tag = "OTIMIZACAO"
            $Button.ToolTip = "Desabilita serviços e limpa pastas com arquivos temporarios."
        }
    }
# ========================================================
# ESTILO DOS BOTÕES - Conf. botoes reativos ou informativos
# ========================================================
    if (
        $Name -eq "BIOS" -or
        $Name -eq "UPDATE" -or
        $Name -eq "PRINT"
    ) {
        $Button.Style = $Window.FindResource(
            "InformativeButton"
        )
    }
    else {
        $Button.Style = $Window.FindResource(
            "MenuButton"
        )
    }
    # LED - Monitorados na Sessao Update-Status.
    if ($Name -eq "7ZIP") {
    $Button.ApplyTemplate()
    Set-ButtonLed -Button $Button -Color "#C62828"
	}
	if ($Name -eq "OTIMIZACAO") {
		$Button.ApplyTemplate()
		Set-ButtonLed -Button $Button -Color "#8A9199"
	}
    $Buttons[$Name] = $Button
    $ButtonsPanel.Children.Add($Button) | Out-Null
}
# ============================================================
# REFERÊNCIAS DOS BOTÕES - Vincular add.Click ao Nome no switch
# ============================================================
$BtnBIOS     = $Buttons["BIOS"]
$BtnADMIN    = $Buttons["ADMIN"]
$BtnFIREWALL = $Buttons["FIREWALL"]
$BtnDOMINIO  = $Buttons["DOMINIO"]
$BtnCHROME  = $Buttons["CHROME"]
$BtnPASTAS   = $Buttons["PASTAS"]
$BtnRDP      = $Buttons["RDP"]
$BtnUPDATE   = $Buttons["UPDATE"]
$BtnOFFICE   = $Buttons["OFFICE"]
$BtnFIREBIRD = $Buttons["FIREBIRD"]
$BtnGESTHOS  = $Buttons["GESTHOS"]
$BtnENERGIA  = $Buttons["ENERGIA"]
$BtnVNC      = $Buttons["VNC"]
$BtnPRINT    = $Buttons["PRINT"]
$Btn7ZIP     = $Buttons["7ZIP"]
$BtnOTIMIZACAO = $Buttons["OTIMIZACAO"]
# ============================================================
# FUNÇÃO - ESTADO DOS BOTÕES Reativos a conclusao
# ============================================================
#Configura Estado do BOTAO
function Set-ButtonState {
    param(
        [Parameter(Mandatory)]
        $Button,
        [Parameter(Mandatory)]
        [bool]$Completed
    )
	#SET Cores botoes reativos, verde ou vermelho	
    $Button.ApplyTemplate()
    $Led = $Button.Template.FindName("Led", $Button)
    if ($Led) {
        if ($Completed) {
			#Verde
            $Led.Foreground = "#198754"
        }
        else {
			#Vermelho
            $Led.Foreground = "#C62828"
        }
    }
}
#Configura LED
function Set-ButtonLed {
    param(
        [Parameter(Mandatory)]
        $Button,
        [Parameter(Mandatory)]
        [string]$Color
    )
    $Button.ApplyTemplate()
    $Led = $Button.Template.FindName("Led", $Button)
    if ($Led) {
        $Led.Foreground = $Color
    }
}
#BOTAO Informativo - Executado e nao sera alterado ao concluir etapa - Cinza
function Set-InformativeButton {
    param(
        [Parameter(Mandatory)]
        $Button
    )
    $Button.Background = $Window.FindResource("ButtonGradient")
    $Button.Foreground = "#243447"
    Set-ButtonLed -Button $Button -Color "#8A9199"
}
# ============================================================
# Configura POPUPs Informativos
# ============================================================
function Show-Info {
    param(
        [string]$Message
    )
    [System.Windows.MessageBox]::Show(
        $Window,
        $Message,
        "EzFormat",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Information
    ) | Out-Null
}
# ============================================================
# Configura POPUPs de Erros
# ============================================================
function Show-Error {
    param(
        [string]$Message
    )
    [System.Windows.MessageBox]::Show(
        $Window,
        $Message,
        "EzFormat - Erro",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Error
    ) | Out-Null
}
# ============================================================
# ========= TESTES PARA ESCOLHER COR BOTAO REATIVOS ==========
# ========== SAO REALIZADOS AO ABRIR O EZFORMAT ==============
# ============================================================
# TESTE - ADMINISTRADOR
# ============================================================
function Test-Admin {
    try {
        $User = Get-LocalUser -Name "Administrador"
        if ($User.Enabled) {
            return $true
        }
    }
    catch {
        try {
            $User = Get-LocalUser -Name "Administrator"
            if ($User.Enabled) {
                return $true
            }
        }
        catch {
        }
    }
    return $false
}
# ============================================================
# TESTE - FIREWALL
# ============================================================
function Test-Firewall {
    try {
        $Profiles = Get-NetFirewallProfile
        if (-not $Profiles) {
            return $false
        }
        $Enabled = $Profiles |
            Where-Object {
                $_.Enabled -eq $true
            }
        if ($Enabled) {
            return $false
        }
        return $true
    }
    catch {
        return $false
    }
}
# ============================================================
# TESTE - DOMÍNIO
# ============================================================
function Test-Domain {
    try {
        $Computer = Get-CimInstance Win32_ComputerSystem
        if (
            $Computer.PartOfDomain -and
            $Computer.Domain -ieq $DomainName
        ) {
            return $true
        }
    }
    catch {
    }
    return $false
}
# ============================================================
# TESTE - CHROME
# ============================================================
function Test-Chrome {
    $ChromePaths = @(
        "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
    )
    foreach ($Path in $ChromePaths) {
        if (Test-Path $Path) {
            return $true
        }
    }
    return $false
}
# ============================================================
# TESTE - PASTAS
# ============================================================
function Test-Folders {
    return (
        (Test-Path "C:\Temp") -and
        (Test-Path "C:\Gesthos")
    )
}
# ============================================================
# TESTE - RDP
# ============================================================
function Test-RDP {
    try {
        $Value = Get-ItemPropertyValue `
            -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" `
            -Name "fDenyTSConnections"
        return ($Value -eq 0)
    }
    catch {
        return $false
    }
}
# ============================================================
# TESTE - VISUAL C++ - NECESSARIO PARA OFFICE A SEGUIR
# ============================================================
function Test-VisualCpp {
    try {
        $RegistryPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        foreach ($RegistryPath in $RegistryPaths) {
            $VC = Get-ItemProperty $RegistryPath |
                Where-Object {
                    $_.DisplayName -match "Microsoft Visual C\+\+"
                }

            if ($VC) {
                return $true
            }
        }

    }
    catch {
    }
    return $false
}
# ============================================================
# TESTE - OFFICE
# ============================================================
function Test-Office {
    $Paths = @(
        "${env:ProgramFiles}\Microsoft Office",
        "${env:ProgramFiles(x86)}\Microsoft Office"
    )
    foreach ($Path in $Paths) {
        if (
            $Path -and
            (Test-Path $Path)
        ) {
            return $true
        }
    }
    try {
        $RegistryPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        foreach ($RegistryPath in $RegistryPaths) {
            $Office = Get-ItemProperty $RegistryPath |
                Where-Object {
                    $_.DisplayName -match "Microsoft 365|Microsoft Office"
                }
            if ($Office) {
                return $true
            }
        }
    }
    catch {
    }
    return $false
}
# ============================================================
# TESTE - FIREBIRD
# ============================================================
function Test-Firebird {
    try {
        $Services = Get-CimInstance Win32_Service

        foreach ($Service in $Services) {
            if (
                $Service.Name -match "Firebird" -or
                $Service.DisplayName -match "Firebird"
            ) {
                return $true
            }
        }
    }
    catch {
    }
    try {
        $RegistryPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        foreach ($RegistryPath in $RegistryPaths) {
            $Firebird = Get-ItemProperty $RegistryPath |
                Where-Object {
                    $_.DisplayName -match "Firebird"
                }
            if ($Firebird) {
                return $true
            }
        }
    }
    catch {
    }
    $PossiblePaths = @(
        "C:\Program Files\Firebird",
        "C:\Program Files (x86)\Firebird",
        "C:\Firebird"
		"C:\Firebird"
    )
    foreach ($Path in $PossiblePaths) {
        if (Test-Path $Path) {
            return $true
        }
    }
    return $false
}
# ============================================================
# TESTE - 7-ZIP
# ============================================================
function Test-7Zip {
    $7ZipExe = "C:\Program Files\7-Zip\7z.exe"
    if (Test-Path $7ZipExe) {
        return $true
    }
    return $false
}
# ============================================================
# TESTE - GESTHOS
# ============================================================
function Test-Gesthos {
    return (
        (Test-Path $GesthosExe) -and
        (Test-Path $GesthosShortcut)
    )
}
# ============================================================
# TESTE - ENERGIA
# ============================================================
function Test-Energia {
    try {
        $Scheme = powercfg /getactivescheme 2>$null
        if (
            $Scheme -match "High performance" -or
            $Scheme -match "Alto desempenho"
        ) {
            return $true
        }
    }
    catch {
    }
    return $false
}
# ============================================================
# TESTE - VNC
# ============================================================
function Test-VNC {
    try {
        $Vnc = Get-CimInstance Win32_Product `
            -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Name -match "UltraVNC"
            }
        if ($Vnc) {
            return $true
			}
		}
		catch {
		}
		try {
			$Services = Get-CimInstance Win32_Service `
				-ErrorAction SilentlyContinue
			foreach ($Service in $Services) {
				if (
					$Service.Name -match "uvnc|winvnc" -or
					$Service.DisplayName -match "UltraVNC"
				) {
					return $true
				}
			}
		}
		catch {
		}
		$VncPaths = @(
			"C:\Program Files\uvnc bvba\UltraVNC",
			"C:\Program Files (x86)\uvnc bvba\UltraVNC",
			"C:\Program Files\UltraVNC",
			"C:\Program Files (x86)\UltraVNC"
		)
		foreach ($Path in $VncPaths) {
			if (Test-Path $Path) {
				return $true
			}
			}
			return $false
		}
# ============================================================
# TESTE - WINGET
# ============================================================
function Get-WingetPath {
    try {
        $Command = Get-Command winget.exe `
            -ErrorAction Stop
        return $Command.Source
    }
    catch {
    }
    $PossiblePaths = @(
        "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe",
        "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*\winget.exe"
    )
    foreach ($Path in $PossiblePaths) {
        $Found = Get-ChildItem `
            -Path $Path `
            -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if ($Found) {
            return $Found.FullName
        }
    }
    return $null
}
# ============================================================
# ============== INSTALACOES E ALTERACOES ====================
# ============================================================
# ============================================================
# Executar instalador VNC e importar configuracao
# ============================================================
function Install-VNC {
    try {
        $BtnVNC.IsEnabled = $false
        $BtnVNC.Content = "VNC - COPIANDO..."
        # CAMINHOS e EXECUTAVEIS
        $VncOrigemExe = "\\10.0.0.233\publico\Programas Basicos\VNC - Acesso remoto\UltraVNC1230.exe"
        $VncOrigemIni = "\\10.0.0.233\publico\Programas Basicos\VNC - Acesso remoto\ultravnc.ini"
        $VncTemp = "C:\Temp"
        $VncInstaller = Join-Path $VncTemp "UltraVNC1230.exe"
        $VncConfigTemp = Join-Path $VncTemp "ultravnc.ini"
        $VncExe = "C:\Program Files\uvnc bvba\UltraVNC\winvnc.exe"
        # CRIA C:\TEMP - SE NAO EXISTIR
        if (-not (Test-Path $VncTemp)) {
            New-Item `
                -Path $VncTemp `
                -ItemType Directory `
                -Force |
                Out-Null
        }
        # VERIFICA DISPONIBILIDADE
        if (-not (Test-Path $VncOrigemExe)) {
            Show-Error `
                "O instalador do UltraVNC não foi encontrado na rede ou ServFiles nao disponivel.`n`n" +
                "Origem:`n$VncOrigemExe"
            $BtnVNC.Content = "VNC"
            $BtnVNC.IsEnabled = $true
            return
        }
        if (-not (Test-Path $VncOrigemIni)) {
            Show-Error `
                "O arquivo ultravnc.ini não foi encontrado na rede.`n`n" +
                "Origem:`n$VncOrigemIni"
            $BtnVNC.Content = "VNC"
            $BtnVNC.IsEnabled = $true
            return
        }
        # LIMPA ARQUIVOS ANTIGOS DO TEMP
        if (Test-Path $VncInstaller) {
            Remove-Item `
                -Path $VncInstaller `
                -Force `
                -ErrorAction SilentlyContinue
        }
        if (Test-Path $VncConfigTemp) {
            Remove-Item `
                -Path $VncConfigTemp `
                -Force `
                -ErrorAction SilentlyContinue
        }
        # COPIA INSTALADOR PARA C:\TEMP
        $BtnVNC.Content = "VNC - COPIANDO..."
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host "COPIANDO ULTRAVNC" -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Origem instalador:" -ForegroundColor Yellow
        Write-Host $VncOrigemExe -ForegroundColor Gray
        Write-Host ""
        Write-Host "Destino:" -ForegroundColor Yellow
        Write-Host $VncInstaller -ForegroundColor Gray
        Copy-Item `
            -Path $VncOrigemExe `
            -Destination $VncInstaller `
            -Force `
            -ErrorAction Stop
        # COPIA ULTRAVNC.INI PARA C:\TEMP
        Write-Host ""
        Write-Host "Copiando ultravnc.ini..." -ForegroundColor Cyan
        Copy-Item `
            -Path $VncOrigemIni `
            -Destination $VncConfigTemp `
            -Force `
            -ErrorAction Stop
        # CONFIRMA TRANSFERÊNCIA
        if (-not (Test-Path $VncInstaller)) {
            Show-Error `
                "O UltraVNC1230.exe não foi transferido corretamente para C:\Temp."
            $BtnVNC.Content = "VNC"
            $BtnVNC.IsEnabled = $true
            return
        }
        if (-not (Test-Path $VncConfigTemp)) {
            Show-Error `
                "O ultravnc.ini não foi transferido corretamente para C:\Temp."
            $BtnVNC.Content = "VNC"
            $BtnVNC.IsEnabled = $true
            return
        }
        # EXECUTA INSTALADOR
        $BtnVNC.Content = "VNC - INSTALANDO..."
        Write-Host ""
        Write-Host "Executando UltraVNC1230.exe..." -ForegroundColor Cyan
        Start-Process `
            -FilePath $VncInstaller
        Start-Sleep -Seconds 2
        # PROCURA WINVNC.EXE
        $BtnVNC.Content = "VNC - AGUARDANDO..."
        Write-Host ""
        Write-Host "Procurando winvnc.exe..." -ForegroundColor Cyan
        Write-Host $VncExe -ForegroundColor Gray
        $MaxTentativas = 60
        $Tentativa = 0
        while (-not (Test-Path $VncExe) -and $Tentativa -lt $MaxTentativas) {
            Start-Sleep -Seconds 1
            $Tentativa++
        }
        # WINVNC NÃO ENCONTRADO
        if (-not (Test-Path $VncExe)) {
            Show-Error `
                "O instalador foi executado, porém o winvnc.exe não foi encontrado.`n`n" +
                "Caminho esperado:`n$VncExe"
            $BtnVNC.Content = "VNC"
            $BtnVNC.IsEnabled = $true
            return
        }
        # WINVNC ENCONTRADO
        Write-Host ""
        Write-Host "winvnc.exe encontrado!" -ForegroundColor Green
        Write-Host $VncExe -ForegroundColor Green
        Write-Host ""
        Write-Host "Aguardando 10 segundos antes de substituir o ultravnc.ini..." `
            -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        # COPIA ULTRAVNC.INI PARA A INSTALAÇÃO FORÇANDO SUBSTITUIÇÃO
        $BtnVNC.Content = "VNC - CONFIGURANDO..."
        $VncConfigDestino = "C:\Program Files\uvnc bvba\UltraVNC\ultravnc.ini"
        Write-Host ""
        Write-Host "Substituindo ultravnc.ini..." -ForegroundColor Cyan
        Write-Host "Origem:" -ForegroundColor Yellow
        Write-Host $VncConfigTemp -ForegroundColor Gray
        Write-Host ""
        Write-Host "Destino:" -ForegroundColor Yellow
        Write-Host $VncConfigDestino -ForegroundColor Gray
        try {
            Copy-Item `
                -Path $VncConfigTemp `
                -Destination $VncConfigDestino `
                -Force `
                -ErrorAction Stop
        }
        catch {
            Show-Error `
                "Não foi possível substituir o ultravnc.ini.`n`n" +
                "Origem:`n$VncConfigTemp`n`n" +
                "Destino:`n$VncConfigDestino`n`n" +
                "Erro:`n$($_.Exception.Message)"
            $BtnVNC.Content = "VNC"
            $BtnVNC.IsEnabled = $true
            return
        }
        # CONFIRMA CONFIGURAÇÃO
        if (-not (Test-Path $VncConfigDestino)) {
            Show-Error `
                "O ultravnc.ini não foi encontrado no diretório de instalação após a cópia."
            $BtnVNC.Content = "VNC"
            $BtnVNC.IsEnabled = $true
            return
        }
        Write-Host ""
        Write-Host "ultravnc.ini substituído com sucesso!" -ForegroundColor Green
        # LOCALIZA SERVIÇO ULTRAVNC
        $BtnVNC.Content = "VNC - SERVIÇO..."
        $VncService = Get-Service `
            -Name "uvnc_service" `
            -ErrorAction SilentlyContinue
        if (-not $VncService) {
            $VncService = Get-Service `
                -Name "UltraVNC" `
                -ErrorAction SilentlyContinue
        }
        # INICIA / REINICIA SERVIÇO
        if ($VncService) {
            try {
                if ($VncService.Status -eq "Running") {
                    Restart-Service `
                        -Name $VncService.Name `
                        -Force `
                        -ErrorAction Stop
                }
                else {
                    Start-Service `
                        -Name $VncService.Name `
                        -ErrorAction Stop
                }
            }
            catch {
                Write-Host `
                    "Aviso: não foi possível reiniciar o serviço UltraVNC." `
                    -ForegroundColor Yellow
            }
        }
        # LIMPA C:\TEMP
        if (Test-Path $VncInstaller) {
            Remove-Item `
                -Path $VncInstaller `
                -Force `
                -ErrorAction SilentlyContinue
        }
        if (Test-Path $VncConfigTemp) {
            Remove-Item `
                -Path $VncConfigTemp `
                -Force `
                -ErrorAction SilentlyContinue
        }
        # FINALIZA
        $BtnVNC.Content = "VNC"
        $BtnVNC.IsEnabled = $true
        Show-Info `
            "UltraVNC instalado e configurado com sucesso.`n`n" +
            "Configuração ultravnc.ini aplicada."
        # ATUALIZA STATUS
        Update-Status
    }
    catch {
        $BtnVNC.Content = "VNC"
        $BtnVNC.IsEnabled = $true
        Show-Error `
            "Erro durante a instalação/configuração do UltraVNC.`n`n" +
            "$($_.Exception.Message)"
    }
}
# ============================================================
# CHROME - WINGET w11 ou INSTALADOR w10
# ============================================================
function Install-Chrome {
    try {
        $BtnCHROME.IsEnabled = $false
        $BtnCHROME.Content = "CHROME - ⏳ AGUARDANDO..."
        # DETECTA A VERSÃO DO WINDOWS
        $WindowsInfo = Get-CimInstance `
            -ClassName Win32_OperatingSystem `
            -ErrorAction Stop
        $WindowsBuild = [int]$WindowsInfo.BuildNumber
        # CAMINHOS DO CHROME
        $ChromePaths = @(
            "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
            "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
            "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
        )
        $ChromeExe = $null
        foreach ($Path in $ChromePaths) {
            if (Test-Path $Path) {
                $ChromeExe = $Path
                break
            }
        }
        # DEFINE O MÉTODO DE INSTALAÇÃO
        $MetodoInstalacao = $null
        if (-not $ChromeExe) {
            # WINDOWS 11
            if ($WindowsBuild -ge 22000) {
                # POPUP PARA ESCOLHER O MÉTODO DE INSTALAÇÃO
                $Escolha = [System.Windows.MessageBox]::Show(
                    "Deseja instalar o Google Chrome via Winget?`n`n" +
                    "Sim > Instalação via Winget 'Exige IP\Rede liberada'`n" +
                    "Não > Instalação via FileServer '10.0.0.233'`n" +
                    "Cancelar > Não será instalado",
                    "Instalação do Google Chrome",
                    [System.Windows.MessageBoxButton]::YesNoCancel,
                    [System.Windows.MessageBoxImage]::Question
                )
                switch ($Escolha) {
                    "Yes" {
                        $MetodoInstalacao = "WINGET"
                    }
                    "No" {
                        $MetodoInstalacao = "FILESERVER"
                    }
                    "Cancel" {
                        $BtnCHROME.Content = "CHROME"
                        $BtnCHROME.IsEnabled = $true
                        return
                    }
                }
            }
            # WINDOWS 10
            elseif ($WindowsBuild -ge 10240 -and $WindowsBuild -lt 22000) {
                $MetodoInstalacao = "FILESERVER"
            }
            else {
                throw "Sistema operacional não suportado: $($WindowsInfo.Caption) - Build $WindowsBuild"
            }
            # ==================================================
            # OPÇÃO 1 - WINGET
            # ==================================================
            if ($MetodoInstalacao -eq "WINGET") {
                $Winget = Get-Command winget.exe -ErrorAction SilentlyContinue
                if (-not $Winget) {
                    throw "O WinGet não está instalado ou não está disponível neste computador."
                }
				$BtnCHROME.IsEnabled = $false
                $BtnCHROME.Content = "CHROME - ⏳ WINGET..."
                $InstallProcess = Start-Process `
                    -FilePath $Winget.Source `
                    -ArgumentList @(
                        "install"
                        "--id"
                        "Google.Chrome"
                        "--exact"
                        "--silent"
                        "--accept-source-agreements"
                        "--accept-package-agreements"
                    ) `
                    -Wait `
                    -PassThru `
                    -NoNewWindow
                if (
                    $InstallProcess.ExitCode -ne 0 -and
                    $InstallProcess.ExitCode -ne 3010
                ) {
                    throw "A instalação do Chrome pelo WinGet falhou. Código: $($InstallProcess.ExitCode)"
                }
            }
            # ==================================================
            # OPÇÃO 2 - FILESERVER
            # WINDOWS 10 TAMBÉM UTILIZA ESTE MÉTODO
            # ==================================================
			elseif ($MetodoInstalacao -eq "FILESERVER") {
                # CAMINHO DO INSTALADOR NA REDE
                $Origem = "\\10.0.0.233\publico\Programas Basicos\Chrome - Navegador\ChromeSetup.exe"
                # DESTINO LOCAL
                $PastaDestino = "C:\Temp"
                $Instalador = Join-Path $PastaDestino "ChromeSetup.exe"
                # CRIA A PASTA TEMP
                if (-not (Test-Path $PastaDestino)) {
                    New-Item `
                        -Path $PastaDestino `
                        -ItemType Directory `
                        -Force `
                        -ErrorAction Stop | Out-Null
                }
				# SE O INSTALADOR NÃO EXISTIR LOCALMENTE, COPIA DA REDE
				if (-not (Test-Path $Instalador)) {
                # VERIFICA O INSTALADOR NA REDE
                if (-not (Test-Path $Origem)) {
                    throw "O instalador do Chrome não foi encontrado no compartilhamento:`n$Origem"
                }
                # COPIA O INSTALADOR
				$BtnCHROME.IsEnabled = $false
                $BtnCHROME.Content = "CHROME - ⏳ COPIANDO..."
                Copy-Item `
                    -Path $Origem `
                    -Destination $Instalador `
                    -Force `
                    -ErrorAction Stop
					if (-not (Test-Path $Instalador)) {
						throw "Não foi possível copiar o instalador para:`n$Instalador"
					}
				}
                # EXECUTA A INSTALAÇÃO
				$BtnCHROME.IsEnabled = $false
                $BtnCHROME.Content = "CHROME - ⏳ INSTALANDO..."
                $InstallProcess = Start-Process `
                    -FilePath $Instalador `
                    -ArgumentList "/silent", "/install" `
                    -Wait `
                    -PassThru
                # VERIFICA CÓDIGO DE RETORNO
                if (
                    $InstallProcess.ExitCode -ne 0 -and
                    $InstallProcess.ExitCode -ne 3010
                ) {
                    throw "A instalação local do Chrome falhou. Código: $($InstallProcess.ExitCode)"
                }
				}
			}
        # ==================================================
        # AGUARDA O CHROME APARECER
        # ==================================================
		$BtnCHROME.IsEnabled = $false
        $BtnCHROME.Content = "CHROME - ⏳ AGUARDANDO..."
        $ChromeExe = $null
        for ($i = 1; $i -le 15; $i++) {
            foreach ($Path in $ChromePaths) {
                if (Test-Path $Path) {
                    $ChromeExe = $Path
                    break
                }
            }
            if ($ChromeExe) {
                break
            }
            Start-Sleep -Seconds 1
        }
        if (-not $ChromeExe) {
            throw "O processo de instalação terminou, mas o executável do Chrome não foi localizado."
        }
        # ==================================================
        # CRIA ATALHO NA ÁREA DE TRABALHO PÚBLICA
        # ==================================================
        $PublicDesktop = [Environment]::GetFolderPath(
            [Environment+SpecialFolder]::CommonDesktopDirectory
        )
        $ChromeShortcut = Join-Path $PublicDesktop "Google Chrome.lnk"
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($ChromeShortcut)
        $Shortcut.TargetPath = $ChromeExe
        $Shortcut.WorkingDirectory = Split-Path $ChromeExe
        $Shortcut.Description = "Google Chrome"
        $Shortcut.Save()
        # ==================================================
        # FINALIZA
        # ==================================================
        $BtnCHROME.Content = "CHROME"
        $BtnCHROME.IsEnabled = $true
        Update-Status
        Show-Info `
            "Google Chrome instalado com sucesso.`n`n" +
            "Sistema operacional: $($WindowsInfo.Caption)`n" +
            "Método de instalação: $MetodoInstalacao`n`n" +
            "Executável:`n$ChromeExe`n`n" +
            "Atalho criado na Área de Trabalho Pública."
    }
    catch {
        $BtnCHROME.Content = "CHROME"
        $BtnCHROME.IsEnabled = $true
        Update-Status
        Show-Error `
            "Erro durante a instalação do Google Chrome.`n`n" +
            "$($_.Exception.Message)"
    }
}
# ============================================================
# 7-ZIP - WINGET w11 ou INSTALADOR w10
# ============================================================
function Install-7Zip {
    try {
        $Btn7ZIP.IsEnabled = $false
        $Btn7ZIP.Content = "7-ZIP - ⏳ AGUARDANDO..."
        # DETECTA A VERSÃO DO WINDOWS
        $WindowsInfo = Get-CimInstance `
            -ClassName Win32_OperatingSystem `
            -ErrorAction Stop
        $WindowsBuild = [int]$WindowsInfo.BuildNumber
        # CAMINHO PADRÃO DO 7-ZIP
        $7ZipExe = "C:\Program Files\7-Zip\7z.exe"
        # ==================================================
        # DEFINE O MÉTODO DE INSTALAÇÃO
        # ==================================================
        $MetodoInstalacao = $null
        if (-not (Test-Path $7ZipExe)) {
            # WINDOWS 11
            if ($WindowsBuild -ge 22000) {
                # POPUP PARA ESCOLHER O MÉTODO DE INSTALAÇÃO
                $Escolha = [System.Windows.MessageBox]::Show(
                    "Deseja instalar o 7-Zip via Winget?`n`n" +
                    "Sim > Instalação via WINGET 'Exige IP\Rede liberada'`n" +
                    "Não > Instalação via FILESERVER '10.0.0.233'`n`n" +
                    "Cancelar > Não será instalado",
                    "Instalação do 7-Zip",
                    [System.Windows.MessageBoxButton]::YesNoCancel,
                    [System.Windows.MessageBoxImage]::Question
                )
                switch ($Escolha) {
                    "Yes" {
                        $MetodoInstalacao = "WINGET"
                    }
                    "No" {
                        $MetodoInstalacao = "FILESERVER"
                    }
                    "Cancel" {
                        $Btn7ZIP.Content = "7-ZIP"
                        $Btn7ZIP.IsEnabled = $true
                        Set-ButtonState $Btn7ZIP $true
                        return
                    }
                }
            }
            # WINDOWS 10
            elseif ($WindowsBuild -ge 10240 -and $WindowsBuild -lt 22000) {
                $MetodoInstalacao = "FILESERVER"
            }
            else {
                throw "Sistema operacional não suportado: $($WindowsInfo.Caption) - Build $WindowsBuild"
            }
            # ==================================================
            # OPÇÃO 1 - WINGET
            # ==================================================
            if ($MetodoInstalacao -eq "WINGET") {
                # LOCALIZA WINGET
                $Winget = Get-Command winget.exe -ErrorAction SilentlyContinue
                if (-not $Winget) {
                    throw "O WinGet não está instalado ou não está disponível neste computador."
                }
				$BtnCHROME.IsEnabled = $false
                $Btn7ZIP.Content = "7-ZIP - ⏳ WINGET..."
                $InstallProcess = Start-Process `
                    -FilePath $Winget.Source `
                    -ArgumentList @(
                        "install"
                        "--id"
                        "7zip.7zip"
                        "--exact"
                        "--silent"
                        "--accept-source-agreements"
                        "--accept-package-agreements"
                    ) `
                    -Wait `
                    -PassThru `
                    -NoNewWindow
                # VERIFICA CÓDIGO DE RETORNO
                if (
                    $InstallProcess.ExitCode -ne 0 -and
                    $InstallProcess.ExitCode -ne 3010
                ) {
                    throw "A instalação do 7-Zip pelo WinGet falhou. Código: $($InstallProcess.ExitCode)"
                }
            }
            # ==================================================
            # OPÇÃO 2 - FILESERVER
            # WINDOWS 10 TAMBÉM UTILIZA ESTE MÉTODO
            # ==================================================
            elseif ($MetodoInstalacao -eq "FILESERVER") {
                # CAMINHO DO INSTALADOR NA REDE
                $Origem = "\\10.0.0.233\publico\Programas Basicos\7Zip\7z.exe"
                # DESTINO LOCAL
                $PastaDestino = "C:\Temp"
                $Instalador = Join-Path $PastaDestino "7z.exe"
                # CRIA A PASTA TEMP
                if (-not (Test-Path $PastaDestino)) {
                    New-Item `
                        -Path $PastaDestino `
                        -ItemType Directory `
                        -Force `
                        -ErrorAction Stop | Out-Null
                }
				if (-not (Test-Path $Instalador)) {
                # VERIFICA SE O ARQUIVO EXISTE NA REDE
                if (-not (Test-Path $Origem)) {
                    throw "O instalador do 7-Zip não foi encontrado no compartilhamento:`n$Origem"
                }
                # COPIA O INSTALADOR
                $Btn7ZIP.Content = "7-ZIP - ⏳ COPIANDO..."
                Copy-Item `
                    -Path $Origem `
                    -Destination $Instalador `
                    -Force `
                    -ErrorAction Stop
					# VERIFICA SE A CÓPIA FOI REALIZADA
					if (-not (Test-Path $Instalador)) {
						throw "Não foi possível copiar o instalador para:`n$Instalador"
					}
				}
                # EXECUTA O INSTALADOR
                $Btn7ZIP.Content = "7-ZIP - ⏳ INSTALANDO..."
                $InstallProcess = Start-Process `
                    -FilePath $Instalador `
                    -Wait `
                    -PassThru
                # VERIFICA CÓDIGO DE RETORNO
                if (
                    $InstallProcess.ExitCode -ne 0 -and
                    $InstallProcess.ExitCode -ne 3010
                ) {
                    throw "A execução do instalador do 7-Zip falhou. Código: $($InstallProcess.ExitCode)"
                }
            }
        }
        # ==================================================
        # VERIFICA INSTALAÇÃO
        # ==================================================
        $Btn7ZIP.Content = "7-ZIP - ⏳ VERIFICANDO..."
        $Encontrado = $false
        for ($i = 1; $i -le 15; $i++) {
            if (Test-Path $7ZipExe) {
                $Encontrado = $true
                break
            }
            Start-Sleep -Seconds 1
        }
        if (-not $Encontrado) {
            throw "O processo de instalação terminou, mas o executável do 7-Zip não foi encontrado em:`n$7ZipExe"
        }
        # ==================================================
        # INSTALAÇÃO CONCLUÍDA
        # ==================================================
        $Btn7ZIP.Content = "7-ZIP"
        $Btn7ZIP.IsEnabled = $true
        Set-ButtonState $Btn7ZIP $true
        Update-Status
        Show-Info `
            "Instalação concluída.`n`n" +
            "O 7-Zip foi instalado com sucesso.`n`n" +
            "Sistema operacional: $($WindowsInfo.Caption)`n" +
            "Método de instalação: $(if ($MetodoInstalacao) { $MetodoInstalacao } else { 'Já instalado' })`n`n" +
            "Executável:`n$7ZipExe"
    }
    catch {
        $Btn7ZIP.Content = "7-ZIP"
        $Btn7ZIP.IsEnabled = $true
        Set-ButtonState $Btn7ZIP $false
        # ATUALIZA STATUS
        Update-Status
        Show-Error `
            "Erro durante a instalação do 7-Zip.`n`n" +
            "$($_.Exception.Message)"
    }
}
# ============================================================
# Impressao 10.0.0.206 - Abertura pasta de impressoras
# ============================================================
$BtnPRINT.Add_Click({
    try {
		$BtnPRINT.IsEnabled = $false
        $BtnPRINT.Content = "⏳ Em progresso..."
		$Window.Dispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
        # VERIFICAR DOMÍNIO
        if (-not (Test-Domain)) {
            Show-Info `
                "Esta máquina não está ingressada no domínio $DomainName.`n`n" +
                "É necessário ingressar a máquina no domínio antes de acessar o servidor de impressão."
            return
        }
        # MÁQUINA ESTÁ NO DOMÍNIO
        Start-Process `
            -FilePath "explorer.exe" `
            -ArgumentList "`"\\10.0.0.206`""
		$BtnPRINT.Content = "⏳ Abrindo mapeamento..."
        $Window.Dispatcher.Invoke(
            [Action]{},
            [System.Windows.Threading.DispatcherPriority]::Background
        )
		Start-Sleep -Seconds 20		
        # ABRIR DISPOSITIVOS E IMPRESSORAS
		$BtnPRINT.Content = "⏳ Abrindo impressoras..."
        $Window.Dispatcher.Invoke(
            [Action]{},
            [System.Windows.Threading.DispatcherPriority]::Background
        )
        Start-Process `
            -FilePath "explorer.exe" `
            -ArgumentList "shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A}"
    }
    catch {
        Show-Error `
            "Não foi possível acessar o servidor de impressão.`n`n$($_.Exception.Message)"
    }
	finally {
        # RESTAURAR BOTÃO
        $BtnPRINT.Content = "IMPRESSÃO"
        $BtnPRINT.IsEnabled = $true
    }
})
# ============================================================
# OTIMIZAÇÃO - POPUP COM ESCOLHA
# ============================================================
function Show-Otimizacao {
    try {
        # ====================================================
        # JANELA AJUSTE TAMANHO
        # ====================================================
        $OptimizationWindow = New-Object System.Windows.Window
        $OptimizationWindow.Title = "Otimização do Windows"
        $OptimizationWindow.Width = 500
        $OptimizationWindow.Height = 330
        $OptimizationWindow.WindowStartupLocation = "CenterScreen"
        $OptimizationWindow.ResizeMode = "NoResize"
        $OptimizationWindow.Topmost = $true
        $OptimizationWindow.Owner = $Window
        $OptimizationWindow.FontFamily = "Segoe UI"
        $OptimizationWindow.Background = "#F4F6F8"
        # ====================================================
        # GRID - CONFIGURAR CONTROLES
        # ====================================================
        $Grid = New-Object System.Windows.Controls.Grid
        $Grid.Margin = "20"
        $Grid.RowDefinitions.Add(
            (New-Object System.Windows.Controls.RowDefinition)
        )
        $Grid.RowDefinitions.Add(
            (New-Object System.Windows.Controls.RowDefinition)
        )
        $Grid.RowDefinitions.Add(
            (New-Object System.Windows.Controls.RowDefinition)
        )
        $Grid.RowDefinitions.Add(
            (New-Object System.Windows.Controls.RowDefinition)
        )
        $Grid.RowDefinitions.Add(
            (New-Object System.Windows.Controls.RowDefinition)
        )
        # ====================================================
        # TÍTULO
        # ====================================================
        $Title = New-Object System.Windows.Controls.TextBlock
        $Title.Text = "Otimização"
        $Title.FontSize = 20
        $Title.FontWeight = "SemiBold"
        $Title.Foreground = "#202428"
        $Title.Margin = "0,0,0,10"
        [System.Windows.Controls.Grid]::SetRow($Title, 0)
        $Grid.Children.Add($Title)
        # ====================================================
        # DESCRIÇÃO
        # ====================================================
        $Description = New-Object System.Windows.Controls.TextBlock
        $Description.Text = "Digite uma ou mais opções separadas por vírgula:"
        $Description.FontSize = 13
        $Description.Foreground = "#707780"
        $Description.Margin = "0,0,0,8"
        [System.Windows.Controls.Grid]::SetRow($Description, 1)
        $Grid.Children.Add($Description)
        # ====================================================
        # OPÇÕES
        # ====================================================
        $Options = New-Object System.Windows.Controls.TextBlock
        $Options.Text = @"
1. Desativar SysMain
2. Limpar temporário
"@
        $Options.FontSize = 14
        $Options.Foreground = "#343A40"
        $Options.Margin = "0,0,0,10"
        [System.Windows.Controls.Grid]::SetRow($Options, 2)
        $Grid.Children.Add($Options)
        # ====================================================
        # CAMPO
        # ====================================================
        $TxtOptions = New-Object System.Windows.Controls.TextBox
        $TxtOptions.FontSize = 16
        $TxtOptions.Height = 35
        $TxtOptions.VerticalContentAlignment = "Center"
        $TxtOptions.ToolTip = "Exemplo: 1,2"
        [System.Windows.Controls.Grid]::SetRow($TxtOptions, 3)
        $Grid.Children.Add($TxtOptions)
        # ====================================================
        # BOTÃO OK
        # ====================================================
        $BtnOK = New-Object System.Windows.Controls.Button
        $BtnOK.Content = "OK"
        $BtnOK.Width = 90
        $BtnOK.Height = 35
        $BtnOK.HorizontalAlignment = "Right"
        $BtnOK.Margin = "0,12,0,0"
        $BtnOK.FontWeight = "SemiBold"
        [System.Windows.Controls.Grid]::SetRow($BtnOK, 4)
        $Grid.Children.Add($BtnOK)
        # ====================================================
        # CONTEÚDO
        # ====================================================
        $OptimizationWindow.Content = $Grid
        # ====================================================
        # BOTÃO OK - CONFIGURACAO
        # ====================================================
        $BtnOK.Add_Click({
            try {
                $Input = $TxtOptions.Text.Trim()
                if ([string]::IsNullOrWhiteSpace($Input)) {
                    [System.Windows.MessageBox]::Show(
                        $OptimizationWindow,
                        "Digite pelo menos uma opção.",
                        "Otimização",
                        [System.Windows.MessageBoxButton]::OK,
                        [System.Windows.MessageBoxImage]::Warning
                    ) | Out-Null
                    return
                }
                # ------------------------------------------------
                # CRIA SEPARACAO DAS OPCOES POR VIRGULA
                # ------------------------------------------------
                $SelectedOptions = $Input -split "," |
                    ForEach-Object {
                        $_.Trim()
                    } |
                    Where-Object {
                        $_
                    }
                # ------------------------------------------------
                # VALIDA AS OPÇÕES 
                # ------------------------------------------------
                $InvalidOptions = $SelectedOptions |
                    Where-Object {
                        $_ -notin @("1","2")
                    }
                if ($InvalidOptions) {
                    [System.Windows.MessageBox]::Show(
                        $OptimizationWindow,
                        "Opção inválida:`n`n$($InvalidOptions -join ', ')`n`nUse somente:`n1 ou 2`n`nExemplo: 1,2",
                        "Otimização",
                        [System.Windows.MessageBoxButton]::OK,
                        [System.Windows.MessageBoxImage]::Warning
                    ) | Out-Null
                    return
                }
                $BtnOK.IsEnabled = $false
                # =================================================
                # OPÇÃO 1 - DESATIVAR SYSMAIN
                # =================================================
                if ($SelectedOptions -contains "1") {
                    try {
                        $SysMain = Get-Service `
                            -Name "SysMain" `
                            -ErrorAction SilentlyContinue
                        if ($SysMain) {
                            if ($SysMain.Status -eq "Running") {
                                Stop-Service `
                                    -Name "SysMain" `
                                    -Force `
                                    -ErrorAction SilentlyContinue
                            }
                            Set-Service `
                                -Name "SysMain" `
                                -StartupType Disabled `
                                -ErrorAction Stop
                        }
                    }
                    catch {
                        throw "Não foi possível desativar o serviço SysMain.`n`n$($_.Exception.Message)"
                    }
                }
                # =================================================
                # OPÇÃO 2 - LIMPAR TEMPORÁRIO
                # =================================================
                if ($SelectedOptions -contains "2") {
                    try {
                        $WindowsTemp = "C:\Windows\Temp"
                        if (Test-Path $WindowsTemp) {
                            Get-ChildItem `
                                -Path $WindowsTemp `
                                -Force `
                                -ErrorAction SilentlyContinue |
                            Remove-Item `
                                -Recurse `
                                -Force `
                                -ErrorAction SilentlyContinue
                        }
                        $UserTemp = $env:TEMP
                        if (Test-Path $UserTemp) {
                            Get-ChildItem `
                                -Path $UserTemp `
                                -Force `
                                -ErrorAction SilentlyContinue |
                            Remove-Item `
                                -Recurse `
                                -Force `
                                -ErrorAction SilentlyContinue
                        }
                        $PercentTemp = [Environment]::ExpandEnvironmentVariables("%TEMP%")
                        if (
                            $PercentTemp -and
                            (Test-Path $PercentTemp) -and
                            ($PercentTemp -ne $UserTemp)
                        ) {
                            Get-ChildItem `
                                -Path $PercentTemp `
                                -Force `
                                -ErrorAction SilentlyContinue |
                            Remove-Item `
                                -Recurse `
                                -Force `
                                -ErrorAction SilentlyContinue
                        }
                    }
                    catch {
                        throw "Não foi possível limpar os arquivos temporários.`n`n$($_.Exception.Message)"
                    }
                }
                # =================================================
                # FECHA POPUP
                # =================================================
                $OptimizationWindow.Close()
                # =================================================
                # RESULTADO
                # =================================================
                $Executadas = @()
                if ($SelectedOptions -contains "1") {
                    $Executadas += "SysMain desativado"
                }
                if ($SelectedOptions -contains "2") {
                    $Executadas += "Arquivos temporários limpos"
                }
                Show-Info `
                    "Otimização concluída.`n`n" +
                    ($Executadas -join "`n")
            }
            catch {
                $BtnOK.IsEnabled = $true
                Show-Error `
                    "Erro durante a otimização.`n`n$($_.Exception.Message)"
            }
        })
        # ====================================================
        # ENTER = OK - CONFIGURACAO
        # ====================================================
        $OptimizationWindow.Add_KeyDown({
            param($Sender, $EventArgs)
            if ($EventArgs.Key -eq "Enter") {
                $BtnOK.RaiseEvent(
                    (New-Object System.Windows.RoutedEventArgs(
                        [System.Windows.Controls.Button]::ClickEvent
                    ))
                )
            }
        })
        # ====================================================
        # FOCO
        # ====================================================
        $OptimizationWindow.Add_ContentRendered({
            $TxtOptions.Focus()
        })
        # ====================================================
        # ABRE POPUP
        # ====================================================
        $OptimizationWindow.ShowDialog() | Out-Null
    }
    catch {
        Show-Error `
            "Não foi possível abrir a ferramenta de otimização.`n`n$($_.Exception.Message)"
    }
}
# ============================================================
# STATUS - Atualiza LED caso esteja concluido
# ============================================================
function Update-Status {
    try {
        # BOTÕES MONITORADOS
        $AdminOk    = Test-Admin
        $FirewallOk = Test-Firewall
        $DomainOk   = Test-Domain
        $FoldersOk  = Test-Folders
        $RDPOk      = Test-RDP
        $OfficeOk   = Test-Office
        $FirebirdOk = Test-Firebird
        $GesthosOk  = Test-Gesthos
        $EnergiaOk  = Test-Energia
        $VncOk      = Test-VNC
		$ChromeOk   = Test-Chrome
		$7ZipOk 	= Test-7Zip
        # APLICA ESTADOS
        Set-ButtonState $BtnADMIN    $AdminOk
        Set-ButtonState $BtnFIREWALL $FirewallOk
        Set-ButtonState $BtnDOMINIO  $DomainOk
        Set-ButtonState $BtnPASTAS   $FoldersOk
        Set-ButtonState $BtnRDP      $RDPOk
        Set-ButtonState $BtnOFFICE   $OfficeOk
        Set-ButtonState $BtnFIREBIRD $FirebirdOk
        Set-ButtonState $BtnGESTHOS  $GesthosOk
        Set-ButtonState $BtnENERGIA  $EnergiaOk
        Set-ButtonState $BtnVNC      $VncOk
		Set-ButtonState $BtnCHROME 	$ChromeOk
		Set-ButtonState $Btn7ZIP 	$7ZipOk
        # BOTÕES INFORMATIVOS - Nao alterados
        Set-InformativeButton $BtnBIOS
        Set-InformativeButton $BtnUPDATE
        Set-InformativeButton $BtnPRINT
		Set-InformativeButton $BtnOTIMIZACAO
        # CONTAGEM - Atualiza lista de concluidos
        $Total = 12
        $Completed = @(
            $AdminOk
            $FirewallOk
            $DomainOk
            $FoldersOk
            $RDPOk
            $OfficeOk
            $FirebirdOk
            $GesthosOk
            $EnergiaOk
            $VncOk
			$ChromeOk
			$7ZipOk
        ) |
        Where-Object {
            $_ -eq $true
        }
        $Count = $Completed.Count
        # PORCENTAGEM
        $Percent = [math]::Round(
            ($Count / $Total) * 100
        )
        $ProgressStatus.Value = $Percent
        # TEXTO
        $TxtProgress.Text = "$Count de $Total concluídos"
        if ($Count -eq $Total) {
            $TxtStatus.Text = "Status: Configuração concluída"
            $TxtStatus.Foreground = "#198754"
        }
        elseif ($Count -eq 0) {
            $TxtStatus.Text = "Status: Configuração pendente"
            $TxtStatus.Foreground = "#C62828"
        }
        else {
            $TxtStatus.Text = "Status: Configuração em andamento"
            $TxtStatus.Foreground = "#B06A00"
        }
    }
    catch {
        $TxtStatus.Text = "Status: Erro ao verificar configuração"
        $TxtStatus.Foreground = "#C62828"
    }
}
# ============================================================
# ================= BOTOES CHAMA FUNÇÃO ======================
# ============================================================
# ============================================================
# BOTÃO CHROME
# ============================================================
$BtnCHROME.Add_Click({
    Install-Chrome
})
# ============================================================
# BOTÃO 7-ZIP
# ============================================================
$Btn7ZIP.Add_Click({
    Install-7Zip
})
# ============================================================
# BOTÃO OTIMIZAÇÃO
# ============================================================
$BtnOTIMIZACAO.Add_Click({
    Show-Otimizacao
})
# ============================================================
# BOTÃO VNC
# ============================================================
$BtnVNC.Add_Click({
    Install-VNC
})
# ============================================================
# ============== BOTOES FUNCAO NO CLICK ======================
# ============================================================
# ============================================================
# BOTÃO BIOS
# ============================================================
$BtnBIOS.Add_Click({
    try {
        $Resposta = [System.Windows.MessageBox]::Show(
            $Window,
            "O computador será reiniciado em 10 segundos para entrar no firmware/BIOS.`n`nDeseja continuar?",
            "EzFormat - BIOS",
            [System.Windows.MessageBoxButton]::YesNo,
            [System.Windows.MessageBoxImage]::Warning
        )
        if (
            $Resposta -eq
            [System.Windows.MessageBoxResult]::Yes
        ) {
            Start-Process `
                -FilePath "shutdown.exe" `
                -ArgumentList "/r /fw /t 10"
        }
    }
    catch {
        Show-Error $_.Exception.Message
    }
})
# ============================================================
# BOTÃO ADMIN
# ============================================================
$BtnADMIN.Add_Click({
    try {
        foreach ($UserName in @("user", "x", "admin")) {
            try {
                $User = Get-LocalUser -Name $UserName
                if ($User) {
                    Remove-LocalUser `
                        -Name $UserName `
                        -ErrorAction SilentlyContinue
                }
            }
            catch {
            }
        }
        $AdminUser = $null
        try {
            $AdminUser = Get-LocalUser -Name "Administrador"
        }
        catch {
        }
        if (-not $AdminUser) {
            try {
                $AdminUser = Get-LocalUser -Name "Administrator"
            }
            catch {
            }
        }
        if ($AdminUser) {
            Enable-LocalUser `
                -Name $AdminUser.Name `
                -ErrorAction SilentlyContinue
            $SecurePassword = ConvertTo-SecureString `
                $AdminPassword `
                -AsPlainText `
                -Force
            Set-LocalUser `
                -Name $AdminUser.Name `
                -Password $SecurePassword `
                -ErrorAction SilentlyContinue
        }
        Update-Status
        Show-Info `
            "O administrador local foi habilitado e a senha foi configurada.`n`n" +
            "O computador será reiniciado em 5 segundos."
        Start-Process `
            -FilePath "shutdown.exe" `
            -ArgumentList "/r /f /t 5" `
            -WindowStyle Hidden
    }
    catch {
        Show-Error `
            "Não foi possível configurar o administrador local.`n`n$($_.Exception.Message)"
    }
})
# ============================================================
# BOTÃO FIREWALL
# ============================================================
$BtnFIREWALL.Add_Click({
    try {
        Start-Process `
            -FilePath "netsh.exe" `
            -ArgumentList "advfirewall set allprofiles state off" `
            -WindowStyle Hidden `
            -Wait
        Update-Status
        Show-Info `
            "Firewall do Windows desativado."
    }
    catch {
        Show-Error `
            "Não foi possível alterar o Firewall.`n`n$($_.Exception.Message)"
    }
})
# ============================================================
# BOTÃO DOMÍNIO
# ============================================================
$BtnDOMINIO.Add_Click({
    try {
        # CONFIGURAÇÕES
        $Domain = "fhsfaucc.org"
        # JANELA PARA DIGITAR ID DA NOVA MÁQUINA
        $InputWindow = New-Object System.Windows.Window
        $InputWindow.Title = "Ingressar Máquina no Domínio"
        $InputWindow.Width = 400
        $InputWindow.Height = 180
        $InputWindow.WindowStartupLocation = "CenterScreen"
        $InputWindow.ResizeMode = "NoResize"
        $InputWindow.Topmost = $true
        # Linhas
		$Grid = New-Object System.Windows.Controls.Grid
        $Grid.Margin = "20"
        $Grid.RowDefinitions.Add(
            (New-Object System.Windows.Controls.RowDefinition)
        )
        $Grid.RowDefinitions.Add(
            (New-Object System.Windows.Controls.RowDefinition)
        )
        $Grid.RowDefinitions.Add(
            (New-Object System.Windows.Controls.RowDefinition)
        )
        # TEXTO
        $Label = New-Object System.Windows.Controls.Label
        $Label.Content = "Digite ID da nova máquina:"
        $Label.FontSize = 14
        [System.Windows.Controls.Grid]::SetRow($Label, 0)
        $Grid.Children.Add($Label)
        # CAMPO DO NOME DA MÁQUINA
        $TxtMachineID = New-Object System.Windows.Controls.TextBox
        $TxtMachineID.FontSize = 16
        $TxtMachineID.MaxLength = 8
        [System.Windows.Controls.Grid]::SetRow($TxtMachineID, 1)
        $Grid.Children.Add($TxtMachineID)
        # BOTÃO OK - CONFIGURACAO
        $BtnOK = New-Object System.Windows.Controls.Button
        $BtnOK.Content = "OK"
        $BtnOK.Width = 80
        $BtnOK.Height = 30
        $BtnOK.HorizontalAlignment = "Right"
        [System.Windows.Controls.Grid]::SetRow($BtnOK, 2)
        $Grid.Children.Add($BtnOK)
        $InputWindow.Content = $Grid
        # BOTÃO OK
        $BtnOK.Add_Click({
            $MachineID = $TxtMachineID.Text.Trim().ToUpper()
			# Garante FHSFA em maiúsculo
			$MachineID = $MachineID -replace '^FHSFA', 'FHSFA'
            # VALIDAÇÃO
            if ($MachineID -notmatch '^FHSFA\d{3}$') {
                [System.Windows.MessageBox]::Show(
                    "Digite um ID válido.`n`nFormato obrigatório: FHSFA + 3 números`n`nExemplo: FHSFA001",
                    "ID inválido",
                    "OK",
                    "Warning"
                )
                $TxtMachineID.Focus()
                $TxtMachineID.SelectAll()
                return
           }
            # Guarda o nome da máquina
            $script:NewMachineID = $MachineID
            # Fecha a janela
            $InputWindow.DialogResult = $true
            $InputWindow.Close()
        })
        # ENTER = OK - GARANTE ENTER CONFIRME O OK
        $InputWindow.Add_KeyDown({
            param($Sender, $EventArgs)
            if ($EventArgs.Key -eq "Enter") {
                $BtnOK.RaiseEvent(
                    (New-Object System.Windows.RoutedEventArgs(
                        [System.Windows.Controls.Button]::ClickEvent
                    ))
                )
            }
        })
        # FOCO INICIAL
        $InputWindow.Add_ContentRendered({
            $TxtMachineID.Focus()
        })
        # ABRE JANELA
        $Result = $InputWindow.ShowDialog()
        # Usuário cancelou/fechou
        if ($Result -ne $true) {
            return
        }
        # DADOS VALIDADOS
        $MachineName = $script:NewMachineID
		$CurrentMachineName = $env:COMPUTERNAME 
		# ==================================================== 
		$SameMachineName = $MachineName -eq $CurrentMachineName 
		if ($SameMachineName) { 
		# O nome informado já é o nome atual. 
		# Não será utilizado -NewName. 
		$MachineName = $CurrentMachineName 
		}
        # SOLICITA CREDENCIAIS
        $Credential = Get-Credential `
            -Message "Informe uma conta com permissão para ingressar computadores no domínio $Domain" `
            -UserName "$Domain\"
        # Usuário cancelou o Get-Credential
        if ($null -eq $Credential) {
            [System.Windows.MessageBox]::Show(
                "Operação cancelada pelo usuário.",
                "Ingresso no domínio",
                "OK",
                "Information"
            )
            return
        }
        # CONFIRMAÇÃO
        $Confirmacao = [System.Windows.MessageBox]::Show(
            "Máquina: $MachineName`nDomínio: $Domain`n`nDeseja ingressar esta máquina no domínio?",
            "Confirmar ingresso no domínio",
            "YesNo",
            "Question"
        )
        if ($Confirmacao -ne "Yes") {
            return
        }
		# INGRESSA NO DOMÍNIO
		if ($SameMachineName) {
			# NOME JÁ É O NOME ATUAL
			Add-Computer `
				-DomainName $Domain `
				-Credential $Credential `
				-Force `
				-ErrorAction Stop
		}
		else {
			# NOVO NOME DE MÁQUINA
			Add-Computer `
				-DomainName $Domain `
				-NewName $MachineName `
				-Credential $Credential `
				-Force `
				-ErrorAction Stop
		}
        # SUCESSO
        [System.Windows.MessageBox]::Show(
            "A máquina foi ingressada no domínio com sucesso.`n`n" +
            "Máquina: $MachineName`n" +
            "Domínio: $Domain`n`n" +
            "É necessário reiniciar o computador para concluir a operação.",
            "Ingresso no domínio",
            "OK",
            "Information"
        )
        # PERGUNTA SE DESEJA REINICIAR
        $Restart = [System.Windows.MessageBox]::Show(
            "Deseja reiniciar o computador agora?",
            "Reiniciar computador",
            "YesNo",
            "Question"
        )
        if ($Restart -eq "Yes") {
            Restart-Computer -Force
        }
    }
    catch {
        Show-Error `
            "Não foi possível ingressar o computador no domínio.`n`n$($_.Exception.Message)"
    }
})
# ============================================================
# BOTÃO PASTAS
# ============================================================
$BtnPASTAS.Add_Click({
    try {
		#PASTA TEMP
        New-Item `
            -Path "C:\Temp" `
            -ItemType Directory `
            -Force |
            Out-Null
		#PASTA GESTHOS	
        New-Item `
            -Path "C:\Gesthos" `
            -ItemType Directory `
            -Force |
            Out-Null
		#PERMISSOES	
        Start-Process `
            -FilePath "icacls.exe" `
            -ArgumentList '"C:\Temp" /grant *S-1-1-0:(OI)(CI)F /T /C' `
            -WindowStyle Hidden `
            -Wait
		#PERMISSOES	
        Start-Process `
            -FilePath "icacls.exe" `
            -ArgumentList '"C:\Gesthos" /grant *S-1-1-0:(OI)(CI)F /T /C' `
            -WindowStyle Hidden `
            -Wait
        Update-Status
        Show-Info `
            "As pastas C:\Temp e C:\Gesthos foram criadas e configuradas."
    }
    catch {
        Show-Error `
            "Não foi possível configurar as pastas.`n`n$($_.Exception.Message)"
    }
})
# ============================================================
# BOTÃO RDP - SEGUNDA OPCAO DESABILITADA
# ============================================================
$BtnRDP.Add_Click({
    try {
        Start-Process -FilePath "SystemPropertiesRemote.exe"
    }
    catch {
        Show-Error `
            "Não foi possível abrir as propriedades de Área de Trabalho Remota.`n`n$($_.Exception.Message)"
    }
})
#OPCAO ABRIR JANELA WINDOWS ATUAL DESABILITADO
#$BtnRDP.Add_Click({
#    try {
#        Start-Process `
#            -FilePath "ms-settings:remotedesktop"
#    }
#    catch {
#        Show-Error `
#            "Não foi possível abrir as configurações de Área de Trabalho Remota.`n`n$($_.Exception.Message)"
#    }
#})
#OPCAO ABRIR JANELA DE ACESSO LEGADO
# ============================================================
# BOTÃO WINDOWS UPDATE - ALTERAR  DAR OPCOES
# ============================================================
$BtnUPDATE.Add_Click({
    try {
        Start-Process `
            -FilePath "ms-settings:windowsupdate"
    }
    catch {
        Show-Error `
            "Não foi possível abrir o Windows Update.`n`n$($_.Exception.Message)"
    }
})
# ============================================================
# BOTÃO OFFICE - COM OPCOES
# ============================================================
$BtnOFFICE.Add_Click({
    try {
        # CONFIGURAÇÕES
        $VisualPath = "\\10.0.0.233\publico\Programas Basicos\Office\office 2016\MicrosoftVisual.exe"
        $OfficePath = "\\10.0.0.233\publico\Programas Basicos\Office\office 2016 plus\Office 16 plus Pro\Setup.exe"
        $OfficeDir = "C:\Temp\Office 16 plus Pro"
        # FUNÇÃO: VERIFICAR WINDOWS
        $WindowsBuild = [Environment]::OSVersion.Version.Build
        if ($WindowsBuild -ge 22000) {
            $WindowsVersion = 11
        }
        else {
            $WindowsVersion = 10
        }
        # FUNÇÃO: VERIFICAR VISUAL C++
        function Test-VisualCpp {
            $UninstallPaths = @(
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
            )
            foreach ($RegPath in $UninstallPaths) {
                $InstalledApps = Get-ItemProperty `
                    -Path $RegPath `
                    -ErrorAction SilentlyContinue
                foreach ($App in $InstalledApps) {
                    if (
                        $App.DisplayName -match
                        "^Microsoft Visual C\+\+.*Redistributable"
                    ) {
                        return $true
                    }
                }
            }
            return $false
        }
        # FUNÇÃO: LOCALIZAR EXCEL
        function Get-ExcelPath {
            $ExcelPaths = @(
                "C:\Program Files (x86)\Microsoft Office\root\Office16\EXCEL.EXE",
                "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"
            )
            foreach ($Path in $ExcelPaths) {
                if (Test-Path -LiteralPath $Path) {
                    return $Path
                }
            }
            return $null
        }
        # FUNÇÃO: EXIBIR MENSAGEM
        function Show-OfficeMessage {
            param(
                [string]$Message,
                [string]$Title = "Instalação do Office"
            )
            [System.Windows.Forms.MessageBox]::Show(
                $Message,
                $Title,
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            ) | Out-Null
        }
        # POPUP DE OPÇÕES
        Add-Type -AssemblyName Microsoft.VisualBasic
        $Opcao = [Microsoft.VisualBasic.Interaction]::InputBox(
            "Digite SOMENTE o número da opção desejada:`n`n" +
            "1 - Instalar Visual C++`n" +
            "2 - Instalar Office`n" +
            "3 - Ativação do Office`n`n" +
            "Windows detectado: $WindowsVersion",
            "Gerenciador de Instalação",
            ""
        )
        # VALIDAR OPÇÃO
        if ([string]::IsNullOrWhiteSpace($Opcao)) {
            return
        }
        if ($Opcao -notin @("1", "2", "3")) {
            [System.Windows.Forms.MessageBox]::Show(
                "Opção inválida!`n`nDigite somente 1, 2 ou 3.",
                "Atenção",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            ) | Out-Null
            return
        }
        # OPÇÃO 1 - INSTALAR VISUAL C++
        if ($Opcao -eq "1") {
            # Windows 11
            if ($WindowsVersion -eq 11) {
                Show-OfficeMessage `
                    "Windows 11 detectado.`n`nO sistema já possui suporte ao Visual C++ atual ou superior."
                return
            }
            # Windows 10: verificar instalação
            if (Test-VisualCpp) {
                Show-OfficeMessage `
                    "Microsoft Visual C++ Redistributable já está instalado."
                return
            }
            # Verificar instalador na rede
            if (-not (Test-Path -LiteralPath $VisualPath)) {
                [System.Windows.Forms.MessageBox]::Show(
                    "Não foi possível localizar o instalador do Visual C++:`n`n$VisualPath",
                    "Erro",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                ) | Out-Null
                return
            }
            # Executar instalador
            $Confirmacao = [System.Windows.Forms.MessageBox]::Show(
                "O Visual C++ não foi encontrado.`n`nDeseja iniciar a instalação?",
                "Instalar Visual C++",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Question
            )
            if ($Confirmacao -ne [System.Windows.Forms.DialogResult]::Yes) {
                return
            }
            $Processo = Start-Process `
                -FilePath $VisualPath `
                -Wait `
                -PassThru
            if ($Processo.ExitCode -eq 0) {
                Show-OfficeMessage `
                    "Instalador do Visual C++ finalizado com sucesso."
            }
            elseif ($Processo.ExitCode -eq 3010) {
                Show-OfficeMessage `
                    "Instalação concluída. É necessário reiniciar o computador."
            }
            else {
                [System.Windows.Forms.MessageBox]::Show(
                    "O instalador terminou com o código: $($Processo.ExitCode)",
                    "Erro na instalação",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                ) | Out-Null
            }
            Update-Status
            return
        }
        # OPÇÃO 2 - INSTALAR OFFICE
        if ($Opcao -eq "2") {
            # Verificar Visual C++
            if (-not (Test-VisualCpp)) {
                [System.Windows.Forms.MessageBox]::Show(
                    "O Microsoft Visual C++ não foi encontrado.`n`nInstale primeiro a opção 1 e depois tente novamente.",
                    "Pré-requisito ausente",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Warning
                ) | Out-Null
                return
            }
            # Verificar se Excel já existe
            $Excel = Get-ExcelPath
            if ($Excel) {
                Show-OfficeMessage `
                    "Microsoft Office já está instalado.`n`nExcel encontrado em:`n$Excel"
                return
            }
            # Verificar instalador na rede
            if (-not (Test-Path -LiteralPath $OfficePath)) {
                [System.Windows.Forms.MessageBox]::Show(
                    "Não foi possível acessar o instalador do Office:`n`n$OfficePath",
                    "Erro",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                ) | Out-Null
                return
            }
            # Confirmar instalação
            $Confirmacao = [System.Windows.Forms.MessageBox]::Show(
                "O Office não foi encontrado.`n`nDeseja iniciar a instalação?",
                "Instalar Office",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Question
            )
            if ($Confirmacao -ne [System.Windows.Forms.DialogResult]::Yes) {
                return
            }
            # Executar setup
            Start-Process `
                -FilePath $OfficePath `
                -WorkingDirectory (Split-Path -Parent $OfficePath)
            Show-OfficeMessage `
                "O instalador do Office foi iniciado."
            Update-Status
            return
        }
        # OPÇÃO 3 - VERIFICAR PRÉ-REQUISITOS DO OFFICE
        if ($Opcao -eq "3") {
            # Verificar Visual C++
            if (-not (Test-VisualCpp)) {
                [System.Windows.Forms.MessageBox]::Show(
                    "O Microsoft Visual C++ não foi encontrado.`n`nExecute primeiro a opção 1.",
                    "Pré-requisito ausente",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Warning
                ) | Out-Null
                return
            }
            # Verificar Excel
            $Excel = Get-ExcelPath
            if (-not $Excel) {
                [System.Windows.Forms.MessageBox]::Show(
                    "O Microsoft Excel não foi encontrado.`n`nInstale primeiro o Office pela opção 2.",
                    "Pré-requisito ausente",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Warning
                ) | Out-Null
                return
            }
            # Pré-requisitos atendidos
            [System.Windows.Forms.MessageBox]::Show(
				"Pré-requisitos atendidos!`n`nVisual C++: OK`nExcel: OK`n`nO PowerShell será aberto.",
				"Opção 3",
				[System.Windows.Forms.MessageBoxButtons]::OK,
				[System.Windows.Forms.MessageBoxIcon]::Information
			) | Out-Null

			Start-Process powershell.exe
			Start-Sleep -Seconds 2
			[System.Windows.Forms.SendKeys]::SendWait("cls")
			[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
			[System.Windows.Forms.SendKeys]::SendWait("irm https:\\get.activated.win | iex")
			[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
			Start-Sleep -Seconds 5
			[System.Windows.Forms.SendKeys]::SendWait("2")
			Start-Sleep -Seconds 2
			[System.Windows.Forms.SendKeys]::SendWait("1")
			Start-Sleep -Seconds 25
			[System.Windows.Forms.SendKeys]::SendWait(" ")
			Start-Sleep -Seconds 2
			[System.Windows.Forms.SendKeys]::SendWait("0")
			Start-Sleep -Seconds 2
			[System.Windows.Forms.SendKeys]::SendWait("exit")
			Start-Sleep -Seconds 2
			[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
			#exclusao temporario
			#$ExcelInstalado = (
			#(Test-Path -LiteralPath "C:\Program Files (x86)\Microsoft Office\root\Office16\EXCEL.EXE") -or
			#(Test-Path -LiteralPath "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE")
			#)
			#if ($ExcelInstalado) {
			#Remove-Item -LiteralPath "C:\Temp\Office 16 plus Pro" -Recurse -Force -ErrorAction SilentlyContinue
			#}
			# ATUALIZA STATUS
			Update-Status

			return
        }
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Ocorreu um erro durante a operação:`n`n$($_.Exception.Message)",
            "Erro",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
})
# ============================================================
# BOTÃO FIREBIRD
# ============================================================
$BtnFIREBIRD.Add_Click({
	try {
		# CAMINHOS DO FIREBIRD
		$FirebirdSource = "$Publico\Programas Basicos\Gesthos & Firebird\Firebird2.exe"
		$FirebirdInstaller = "C:\temp\Firebird2.exe"
		# GARANTE QUE C:\temp EXISTE
		if (-not (Test-Path "C:\temp")) {
			New-Item `
				-Path "C:\temp" `
				-ItemType Directory `
				-Force |
				Out-Null
		}
		# VERIFICA O INSTALADOR NO SERVIDOR
		if (-not (Test-Path $FirebirdSource)) {
			Show-Error `
				"Instalador do Firebird não encontrado no servidor:`n`n$FirebirdSource"
			return
		}
		# COPIA O INSTALADOR PARA C:\temp
		Copy-Item `
			-Path $FirebirdSource `
			-Destination $FirebirdInstaller `
			-Force
		# VERIFICA SE A CÓPIA FOI REALIZADA
		if (-not (Test-Path $FirebirdInstaller)) {
			Show-Error `
				"Não foi possível copiar o instalador do Firebird para:`n`n$FirebirdInstaller"
			return
		}
		# EXECUTA INSTALAÇÃO
		Start-Process `
			-FilePath $FirebirdInstaller `
			-Wait	
		# AGUARDA O FBCLIENT.DLL SER CRIADO
		$FirebirdDLL = "C:\Program Files (x86)\Firebird\Firebird_2_5\bin\fbclient.dll"
		$Timeout = 120
		$Elapsed = 0
		while (-not (Test-Path $FirebirdDLL)) {
			Start-Sleep -Seconds 2
			$Elapsed += 2
			if ($Elapsed -ge $Timeout) {
				Show-Error `
					"O instalador do Firebird foi executado, porém o arquivo fbclient.dll não foi encontrado.`n`n" +
					"Esperado em:`n$FirebirdDLL"
				Remove-Item `
					-Path $FirebirdInstaller `
					-Force `
					-ErrorAction SilentlyContinue
				return
			}
		}
		# AGUARDA 5 SEGUNDOS APÓS ENCONTRAR A DLL
		Start-Sleep -Seconds 1
		# FIREBIRD INSTALADO COM SUCESSO
		Update-Status
		# REMOVE O INSTALADOR
		Remove-Item `
			-Path $FirebirdInstaller `
			-Force `
			-ErrorAction SilentlyContinue	
	}
	catch {
		Show-Error `
			"Não foi possível instalar o Firebird.`n`n$($_.Exception.Message)"
	}
	})
# ============================================================
# BOTÃO GESTHOS
# ============================================================
$BtnGESTHOS.Add_Click({
    try {
        if (-not (Test-Path $GesthosSource)) {
            Show-Error `
                "Origem do Gesthos não encontrada:`n`n$GesthosSource"
            return
        }
        New-Item `
            -Path $GesthosDestination `
            -ItemType Directory `
            -Force |
            Out-Null
        Copy-Item `
            -Path "$GesthosSource\*" `
            -Destination $GesthosDestination `
            -Recurse `
            -Force
        if (-not (Test-Path $GesthosExe)) {
            Show-Error `
                "O Gesthos foi copiado, mas o executável não foi encontrado:`n`n$GesthosExe"
            return
        }
		#CRIACAO DE ATALHO PASTA PUBLICA
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut(
            $GesthosShortcut
        )
        $Shortcut.TargetPath = $GesthosExe
        $Shortcut.WorkingDirectory = $GesthosDestination
        $Shortcut.IconLocation = $GesthosExe
        $Shortcut.Save()
		#ATUALIZA STATUS
        Update-Status
        Show-Info `
            "Gesthos configurado com sucesso.`n`nAtalho criado na Área de Trabalho pública."
    }
    catch {
        Show-Error `
            "Não foi possível configurar o Gesthos.`n`n$($_.Exception.Message)"
    }
})
# ============================================================
# BOTÃO ENERGIA- ALTO DESEMPENHO
# ============================================================
$BtnENERGIA.Add_Click({
    try {
        powercfg /setactive SCHEME_MIN
        powercfg /change standby-timeout-ac 0
        powercfg /change monitor-timeout-ac 0
        powercfg /change disk-timeout-ac 0
		#ATUALIZA STATUS
        Update-Status
        Show-Info `
            "Plano de energia configurado para Alto Desempenho."
    }
    catch {
        Show-Error `
            "Não foi possível configurar a energia.`n`n$($_.Exception.Message)"
    }
})
# ============================================================
# TIMER DE MONITORAMENTO E ATUALIZAR LEDS
# ============================================================
$Timer = New-Object System.Windows.Threading.DispatcherTimer
$Timer.Interval = [TimeSpan]::FromSeconds(30)
$Timer.Add_Tick({
    Update-Status
})
$Timer.Start()
# ============================================================
# PRIMEIRA VERIFICAÇÃO
# ============================================================
Update-Status
# ============================================================
# ENCERRAMENTO
# ============================================================
$Window.Add_Closing({
    try {
        $Timer.Stop()
		##REMOVE CREDENCIAIS DO FILESERVER
        cmdkey.exe /delete:10.0.0.233 2>$null
    }
    catch {
    }
})
# ============================================================
# INICIAR INTERFACE
# ============================================================
$Window.ShowDialog() | Out-Null