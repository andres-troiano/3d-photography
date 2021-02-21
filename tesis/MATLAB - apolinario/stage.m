classdef stage<handle
	
	properties
		
		controller % controlador del stage
		axis % numero de eje del controlador
		position % posicion respecto a la posicion de home
		resolution % resolucion en las unidades units
		units % unidades en las que se mide la posicion
		speed
		
	end
	
	methods
		
		function self = stage(controller, axis)
% 			inicializa el stage enchufado al controlador Newport.
% controller debe ser un handle al objeto controlador con las funciones de
% movimiento y control de los distintos ejes

			self.controller = controller;
			self.axis = axis;
			[self.resolution, self.units] = self.controller.getResolution(self.axis);
			
			self.controller.enableAxis(self.axis);
			self.controller.homeAxis(self.axis);
			self.position = self.controller.getPosition(self.axis);
			self.speed = self.controller.getSpeed(self.axis);

		end
		
		function moveAbs(self, position)
% 			mueve el eje a la posicion absoluta marcada por position

			self.controller.moveAbsAxis(self.axis, position);
			self.position = self.controller.getPosition(self.axis);
			
        end
        
        function moveAbsAsync(self, position)
% 			mueve el eje a la posicion absoluta marcada por position

			self.controller.moveAbsAxisAsync(self.axis, position);
			% Pongo NaN porque no se en que posicion esta, se esta moviendo...
			self.position = NaN;
			
		end
		
		function move(self, distance)
% 			mueve el eje la distancia distance de la posicion actual

			self.controller.moveRelAxis(self.axis, distance);
			self.position = self.controller.getPosition(self.axis);
			
        end
        
        function setSpeed(self, speed)
% 			setea velocidad. warning en caso que no pueda

            self.controller.setSpeed(self.axis, speed);
			self.speed = self.controller.getSpeed(self.axis);
            if self.speed ~= speed
                warningStr = sprintf('Actual actuator speed is %fmm/s', self.speed);
                warning(warningStr)
            end
        end
        
        function position = getPosition(self)
%			actualiza posicion. necesario porque ahora se puede usar "async"

            self.position = self.controller.getPosition(self.axis);
            position = self.position;
        end
        
	end
	
end