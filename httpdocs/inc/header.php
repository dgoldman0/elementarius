<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Elementarius (Pre-Alpha): Open Mana Pack</title>

        <!-- CHARSET AND VIEWPORT METAS AT THE TOP, BELOW TITLE ALWAYS. -->
        <meta charset="utf8">
        <meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1">

        <!-- NOW SOME DESCRIPTION METAS -->
        <meta name="description" content="Elementarius - The Game of Creation">
        <meta name="keywords" content="cryptocurrency, crypto, blockchain, games, arcade">

        <!-- CSS, ICONS AND BOOTSTRAP -->
        <link rel="stylesheet" href="https://bootswatch.com/4/pulse/bootstrap.min.css" />
        <link rel="stylesheet" href="assets/css/elementarius.css" />
        <link rel="icon" type="image/png" href="assets/img/etc.png">

        <!-- FontAwesome -->
        <script src="https://kit.fontawesome.com/f352960784.js" crossorigin="anonymous"></script>
    </head>
    <body class="wallpaper">
      <!-- Global site tag (gtag.js) - Google Analytics -->
      <script async src="https://www.googletagmanager.com/gtag/js?id=G-PLFW1JDGG4"></script>
      <script>
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());

        gtag('config', 'G-PLFW1JDGG4');
      </script>
      <script src='https://storage.ko-fi.com/cdn/scripts/overlay-widget.js'></script>
      <script>
        kofiWidgetOverlay.draw('arcadium', {
          'type': 'floating-chat',
          'floating-chat.donateButton.text': 'Support Us',
          'floating-chat.donateButton.background-color': '#ff5f5f',
          'floating-chat.donateButton.text-color': '#fff'
        });
      </script>
      <header>
        <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
            <a class="navbar-brand" href="index.php"><img src="assets/img/logo.png" width="30px" height="30px" /> Elementarius</a>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarColor02" aria-controls="navbarColor02" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="navbar-nav mr-auto">
              <button type="button" class="btn btn-danger">Fire <span id = "mana-fire" class="badge">#</span></button>
              <button type="button" class="btn btn-info">Air <span id = "mana-air" class="badge">#</span></button>
              <button type="button" class="btn btn-primary">Water <span id = "mana-water" class="badge">#</span></button>
              <button type="button" class="btn btn-success">Earth <span id = "mana-earth" class="badge">#</span></button>
              <button type="button" class="btn btn-light">Light <span id = "mana-light" class="badge">#</span></button>
              <button type="button" class="btn btn-dark">Darkness <span id = "mana-darkness" class="badge">#</span></button>
              <button type="button" class="btn btn-warning">Spirit <span id = "mana-spirit" class="badge">#</span></button>
            </div>
            <div class="collapse navbar-collapse" id="navbarColor02">
              <ul class="navbar-nav ml-auto">
                  <li class="nav-item"><a class="nav-link" href="https://twitter.com/arcadium0"><i class="fab fa-twitter text-white"></i> Twitter</a></li>
              </ul>
              <ul class="navbar-nav mr-auto">
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="dropdown08" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><i class="fas fa-toolbox text-white"></i> [Username]</a>
                    <div class="dropdown-menu bg-primary" aria-labelledby="dropdown08">
                      <a class="dropdown-item text-white" href="/packs.php"><i class="fas fa-toolbox text-white"></i> Open Packs</a><
                    </div>
                </li>
              </ul>
          </div>
      </nav>
    </header>
