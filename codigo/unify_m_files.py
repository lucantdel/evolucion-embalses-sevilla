import os

def unify_m_files(directory, output_file):
    # Lista para almacenar el contenido de todos los archivos
    all_content = []
    
    # Contador para numerar los archivos
    counter = 1
    
    # Recorrer todos los archivos .m en el directorio
    for filename in sorted(os.listdir(directory)):
        if filename.endswith('.m'):
            file_path = os.path.join(directory, filename)
            
            # Leer el contenido del archivo
            with open(file_path, 'r') as file:
                content = file.read()
            
            # Añadir el comentario con el contador y el nombre del archivo
            header = f"% --- [{counter}] {filename} ---\n"
            
            # Añadir el contenido al lista
            all_content.append(header + content + "\n\n")
            
            # Incrementar el contador
            counter += 1
    
    # Escribir todo el contenido en el archivo de salida
    with open(output_file, 'w') as outfile:
        outfile.write("% Archivo combinado con {} funciones\n\n".format(counter - 1))
        outfile.write(''.join(all_content))

# Uso del script
directory = './codigo_labs'  # Reemplaza esto con la ruta a tu directorio
output_file = 'codigo_labs_unificado.m'  # Nombre del archivo de salida

unify_m_files(directory, output_file)
print(f"Los archivos han sido unificados en {output_file}")
