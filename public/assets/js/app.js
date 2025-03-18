window.onload = function() {
  const alerts = document.querySelectorAll('.alert'); // Buscar elementos con la clase 'alert'
  if (alerts.length > 0) {
    alerts.forEach(alert => {
      setTimeout(() => {
        alerts.forEach(alert => {
          alert.classList.add('d-none'); // Agregar la clase de Bootstrap para ocultar
        });
      }, 4300);
    });
  }
};
