# Fotografía 3D

Software desarrollado en MATLAB para la calibración de un sistema de visión 3D por triangulación láser, para ser usado en ensayos no destructivos en la industria metalúrgica de productos tubulares.

En la carpeta "barrido" están los scripts de automatización del experimento, que utiliza posicionadores lineales Newport IMS, junto con el controlador XPS-Q8 del mismo fabricante. El script principal es "medicion.m", y los demás son funciones auxiliares. El experimento consiste en hacer un barrido en el plano del láser, y en cada punto tomar dos fotos, cada una con una cámara diferente, las cuales tienen una inclinación relativa de 60º. Este barrido permite correlacionar las coordenadas en pixels de cada cámara con las coordenadas en mm del "mundo real", medidas por los posicionadores. Estos datos sirven de input para el algoritmo de calibración que se encuentra en la carpeta del mismo nombre.

En la carpeta "calibración" está el script "calibracion.m" y funciones auxiliares. El objetivo de este script es, dado un punto en el espacio de pixels de cada cámara, devolver la posición en mm correspondiente. Para eso hace uso de un modelo matemático propuesto.

## Instalación

No requiere instalación

### Requisitos

Este paquete está pensado para un montaje experimental que no se pretende describir en detalle aquí.
Requiere la librería "XPS_Matlab", disponible en la página web de Newport, la cual contiene los drivers del controlador.

## Autores

* **Andrés Troiano**
* **Martín Argañaraz (colaborador)**

## Licencia

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
