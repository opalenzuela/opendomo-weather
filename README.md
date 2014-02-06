Este paquete simula una estación meteorológica local, cogiendo los datos de la API de Weather Underground: 
http://www.wunderground.com/weather/api

Su funcionamiento es muy basico, pero el objetivo principal es simular recogidas de datos analogicos en entornos sin ODControl ni ODEnergy disponibles

¿Cómo probar este plugin?
=========================

Hasta que opendomo-weather llegue a su primera versión estable, es necesario instalarlo a través del plugin opendomo-devel (https://github.com/opalenzuela/opendomo-devel#how-to-try-it), que debe estar previamente instalado en el sistema.
Para hacerlo, bastará con entrar en la línea de comandos y ejecutar el siguiente comando:

     $ plugin_install_from_gh.sh opalenzuela opendomo-weather

O bien, desde la interfaz web, acceder al script installPluginFromGithub.sh e indicar los valores anteriores para identificar el plugin.
