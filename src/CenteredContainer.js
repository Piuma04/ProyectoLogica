function CenteredContainer({ children }) {
  return (
    <div style={{
      display: 'flex',
      flexDirection:'column',
      justifyContent: 'center',
      alignItems: 'center',
      height: '75vh',
      width: '100%',
      
    }}>
      {children}
    </div>
  );
}

export default CenteredContainer;