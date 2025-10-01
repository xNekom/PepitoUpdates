const axios = require('axios');

async function checkPepitoStatus() {
  try {
    console.log('🔄 Iniciando verificación automática de Pépito...');

    // Llamar a la Edge Function de Supabase
    const response = await axios.post(
      'https://ewxarmlqoowlxdqoebcb.supabase.co/functions/v1/check-pepito-status',
      {},
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${process.env.SUPABASE_ANON_KEY}`
        },
        timeout: 30000
      }
    );

    console.log('Edge Function ejecutada:', response.data);
    return response.data;
  } catch (error) {
    console.error('❌ Error ejecutando Edge Function:', error.message);
    throw error;
  }
}

// Ejecutar inmediatamente
checkPepitoStatus()
  .then(() => {
    console.log('🎉 Verificación completada');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Error fatal:', error);
    process.exit(1);
  });