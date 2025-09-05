// index.js
import nodemailer from "nodemailer";
import { config } from 'dotenv'
config();


export async function enviarCorreo(cantidad, tieneError) {

    try {
        const transporter = nodemailer.createTransport({
            host: process.env.HOST_SMTP,
            port: process.env.HOST_PORT,
            secure: false,
            auth: {
                user: process.env.USER_SMPT,
                pass: process.env.PASS_SMPT,
            },
        });


        const color = tieneError ? "#f44336" : "#4caf50"; // rojo o verde
        const titulo = tieneError ? "⚠️ Error vozy-downloads" : "✅ Exito vozy-downloads";
        const mensaje = tieneError
            ? `Se detectó un error durante la rutina. Solo se insertaron ${cantidad} registros.`
            : `La rutina se ejecutó correctamente. Se insertaron ${cantidad} registros.`;


        const htmlTemplate = `
    <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #ddd;">
      <h2 style="color: ${color};">${titulo}</h2>
      <p style="font-size: 16px; color: #333;">${mensaje}</p>
      <hr />
      <small>Este es un correo automático generado por Node.js</small>
    </div>
  `;


        const info = await transporter.sendMail({
            from: process.env.USER_SMPT,
            to: process.env.SEND_TO_SMTP,
            subject: titulo,
            html: htmlTemplate,
        });

        return { mensaje: "Mensaje enviado" }

    } catch (err) {

        return { mensaje: "Mensaje no enviado"}

    }


}

