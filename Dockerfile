FROM node:22

# 1. Establecer el directorio de trabajo
WORKDIR /app

# 2. Copiar primero los archivos de dependencias
COPY package*.json ./

# 3. Instalar dependencias (se cachea si package.json no cambia)
RUN npm install

# 4. Copiar el resto del código fuente
COPY . .

# 5. Exponer el puerto
EXPOSE 3000

# 6. Iniciar la aplicación
CMD ["npm", "start"]