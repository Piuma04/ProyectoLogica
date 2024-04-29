import bg from './stalin.jpg';
function CenteredContainer({ children }) {
  return (
    <div style={{
      display: 'flex',
      flexDirection:'column',
      justifyContent: 'center',
      alignItems: 'center',
      height: '100vh',
      width: '100vw',
      //backgroundImage: `url(${bg})`,
      backgroundColor: 'yellow',
      backgroundRepeat: 'no-repeat',
      backgroundSize: 'cover',
      margin: 0, // Elimina cualquier margen predeterminado
      padding: 0, // Elimina cualquier relleno predeterminado
    }}>
      {children}
    </div>
  );
}

export default CenteredContainer;