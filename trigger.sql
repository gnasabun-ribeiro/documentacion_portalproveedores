CREATE OR REPLACE FUNCTION public.generar_documentos_personal()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
  v_operadora varchar;
  v_es_constructora boolean;
BEGIN

  SELECT operadora, es_constructora
  INTO v_operadora, v_es_constructora
  FROM public.proveedor
  WHERE cuit = NEW.cuit_proveedor; 

  -- ============================================================
  -- VISTA
  -- ============================================================
  IF v_operadora = 'Vista Energy' THEN

    -- Básica dentro de relacion de dependencia
    IF NEW.tipo_dependencia = 'Relación de dependencia' THEN
      INSERT INTO public.documentacion_persona (cuil_personal, nombre_documento, cargado, tipo_vencimiento) VALUES
        (NEW.cuil, 'DNI/CUIL', false, 'Con vencimiento'),
        (NEW.cuil, 'Alta temprana ARCA', false, 'Con vencimiento'),
        (NEW.cuil, 'Relaciones laborales activas', false, 'Con vencimiento'),
        (NEW.cuil, 'Nómina ART', false, 'Con vencimiento'),
        (NEW.cuil, 'Nómina seguro de vida obligatorio', false, 'Con vencimiento'),
        (NEW.cuil, 'Contrato (eventual/pasantía)', false, 'Con vencimiento'),
        (NEW.cuil, 'PASE (si es petrolero)', false, 'Con vencimiento'),
        (NEW.cuil, 'Libreta sanitaria', false, 'Con vencimiento'),
        (NEW.cuil, 'Visa de trabajo (extranjeros)', false, 'Con vencimiento'),
        (NEW.cuil, 'Exámenes médicos preocupacionales/periódicos vigentes', false, 'Con vencimiento');

      -- Si es conductor dentro de relacion de dependencia
      IF NEW.es_conductor THEN
        INSERT INTO public.documentacion_persona (cuil_personal, nombre_documento, cargado, tipo_vencimiento) VALUES
          (NEW.cuil, 'Licencia de conducir', false, 'Con vencimiento'),
          (NEW.cuil, 'Curso de manejo defensivo', false, 'Con vencimiento'),
          (NEW.cuil, 'Carnet de izaje', false, 'Con vencimiento'),
          (NEW.cuil, 'Certificaciones', false, 'Con vencimiento');
      END IF;

    -- Básica dentro de monotributo
    ELSIF NEW.tipo_dependencia = 'Monotributista' THEN
      INSERT INTO public.documentacion_persona (cuil_personal, nombre_documento, cargado, tipo_vencimiento) VALUES
        (NEW.cuil, 'DNI/CUIL', false, 'Con vencimiento'),
        (NEW.cuil, 'Constancia de monotributo/autónomo + pago', false, 'Con vencimiento'),
        (NEW.cuil, 'Constancia de cuenta bancaria', false, 'Con vencimiento'),
        (NEW.cuil, 'Factura de compra de EPP', false, 'Con vencimiento'),
        (NEW.cuil, 'Seguro de accidentes personales + pago', false, 'Con vencimiento'),
        (NEW.cuil, 'Habilitaciones según tareas', false, 'Con vencimiento');

      -- Si es conductor dentro de monotributo
      IF NEW.es_conductor THEN
        INSERT INTO public.documentacion_persona (cuil_personal, nombre_documento, cargado, tipo_vencimiento) VALUES
          (NEW.cuil, 'Licencia de conducir', false, 'Con vencimiento'),
          (NEW.cuil, 'Curso de manejo defensivo', false, 'Con vencimiento');
      END IF;

    END IF;

  -- ============================================================
  -- YPF
  -- ============================================================
  ELSIF v_operadora = 'YPF' THEN

    IF NEW.tipo_dependencia = 'Relación de dependencia' THEN

      -- Básica dentro de relacion de dependencia
      INSERT INTO public.documentacion_persona (cuil_personal, nombre_documento, cargado, tipo_vencimiento) VALUES
        (NEW.cuil, 'Alta temprana ARCA', false, 'Con vencimiento'),
        (NEW.cuil, 'Relaciones laborales activas', false, 'Con vencimiento'),
        (NEW.cuil, 'DNI/CUIL', false, 'Con vencimiento'),
        (NEW.cuil, 'Contrato (eventual/pasantía)', false, 'Con vencimiento'),
        (NEW.cuil, 'Póliza ART con nómina (cláusula de no repetición)', false, 'Con vencimiento'),
        (NEW.cuil, 'Seguro de vida obligatorio', false, 'Con vencimiento'),
        (NEW.cuil, 'Apto de salud ocupacional (EPAP)', false, 'Con vencimiento'),
        (NEW.cuil, 'Constancia de entrega de EPP firmada', false, 'Con vencimiento'),
        (NEW.cuil, 'PASE (si aplica)', false, 'Con vencimiento');

      -- Si es conductor dentro de relacion de dependencia
      IF NEW.es_conductor THEN
        INSERT INTO public.documentacion_persona (cuil_personal, nombre_documento, cargado, tipo_vencimiento) VALUES
          (NEW.cuil, 'Licencia de conducir', false, 'Con vencimiento'),
          (NEW.cuil, 'Curso de manejo defensivo', false, 'Con vencimiento');
      END IF;

      -- Si es constructora dentro de relacion de dependencia
      IF v_es_constructora THEN
        INSERT INTO public.documentacion_persona (cuil_personal, nombre_documento, cargado, tipo_vencimiento) VALUES
          (NEW.cuil, 'Hoja móvil IERIC', false, 'Con vencimiento');
      END IF;

      -- Si es maquinista en relacion de dependencia
      IF NEW.es_maquinista THEN
        INSERT INTO public.documentacion_persona (cuil_personal, nombre_documento, cargado, tipo_vencimiento) VALUES
          (NEW.cuil, 'Certificación', false, 'Con vencimiento');
      END IF;

      -- Licencia profesional para conductor, constructora o maquinista en relacion de dependencia
      IF NEW.es_conductor OR NEW.es_maquinista OR v_es_constructora THEN
        INSERT INTO public.documentacion_persona (cuil_personal, nombre_documento, cargado, tipo_vencimiento) VALUES
          (NEW.cuil, 'Licencia profesional con las categorías según corresponda su puesto', false, 'Con vencimiento');
      END IF;

      -- Documentacion mensual
      INSERT INTO public.documentacion_persona (cuil_personal, nombre_documento, cargado, tipo_vencimiento) VALUES
        (NEW.cuil, 'Recibos de sueldo firmados', false, 'Mensual'),
        (NEW.cuil, 'Comprobantes de pago bancario', false, 'Mensual'),
        (NEW.cuil, 'Detalle incluido en F931', false, 'Mensual'),
        (NEW.cuil, 'Fondo de desempleo (solo UOCRA)', false, 'Mensual');

    END IF;

  END IF;

  RETURN NEW;
END;
$function$
